import hashlib
import importlib.util
import json
import shutil
import tempfile
import unittest
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'Apply-GEAC-X1-R1.py'
BASELINE = ROOT / 'GEAC_X1_EXPERIMENTAL_BASELINE'
MANIFEST = json.loads((BASELINE / 'X1-PAYLOAD-MANIFEST.json').read_text(encoding='utf-8'))


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def install_fake_home(home: Path) -> None:
    for entry in MANIFEST['files']:
        src = BASELINE / entry['package_path']
        dst = home / Path(entry['target'])
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(src, dst)


def load_module():
    spec = importlib.util.spec_from_file_location('x1r1', SCRIPT)
    if spec is None or spec.loader is None:
        raise RuntimeError('unable to load script')
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


class X1R1PatchTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.home = Path(self.tmp.name)
        install_fake_home(self.home)

    def tearDown(self):
        self.tmp.cleanup()

    def test_apply_changes_only_identity_and_preserves_parent_backup(self):
        mod = load_module()
        before = {
            entry['target']: sha256(self.home / Path(entry['target']))
            for entry in MANIFEST['files']
        }

        result = mod.apply_revision(self.home)

        target = self.home / Path(mod.TARGET_REL)
        self.assertEqual(sha256(target), mod.EXPECTED_R1_SHA256)
        self.assertEqual(result['status'], 'APPLIED_AND_VERIFIED')
        self.assertEqual(result['revision_id'], mod.REVISION_ID)

        changed = []
        for entry in MANIFEST['files']:
            rel = entry['target']
            after = sha256(self.home / Path(rel))
            if after != before[rel]:
                changed.append(rel)
        self.assertEqual(changed, [mod.TARGET_REL])

        backup = Path(result['backup_path'])
        self.assertTrue(backup.is_file())
        self.assertEqual(sha256(backup), mod.PARENT_IDENTITY_SHA256)

        receipt = Path(result['receipt_path'])
        data = json.loads(receipt.read_text(encoding='utf-8'))
        self.assertEqual(data['parent_revision'], 'X1')
        self.assertEqual(data['revision'], 'X1-R1')
        self.assertEqual(data['changed_files'], [mod.TARGET_REL])
        self.assertEqual(data['pre_sha256'][mod.TARGET_REL], mod.PARENT_IDENTITY_SHA256)
        self.assertEqual(data['post_sha256'][mod.TARGET_REL], mod.EXPECTED_R1_SHA256)

    def test_refuses_if_any_parent_managed_file_is_not_exact_x1(self):
        mod = load_module()
        other = self.home / '.gemini/antigravity-cli/skills/geac-x1-engineering-testing.md'
        other.write_bytes(other.read_bytes() + b'\nUNEXPECTED_LOCAL_EDIT\n')

        with self.assertRaisesRegex(RuntimeError, 'PARENT_STATE_MISMATCH'):
            mod.apply_revision(self.home)

        identity = self.home / Path(mod.TARGET_REL)
        self.assertEqual(sha256(identity), mod.PARENT_IDENTITY_SHA256)

    def test_reapply_detects_verified_r1_without_mutating_again(self):
        mod = load_module()
        first = mod.apply_revision(self.home)
        first_hash = sha256(self.home / Path(mod.TARGET_REL))
        second = mod.apply_revision(self.home)
        self.assertEqual(second['status'], 'ALREADY_APPLIED_AND_VERIFIED')
        self.assertEqual(sha256(self.home / Path(mod.TARGET_REL)), first_hash)
        self.assertEqual(first_hash, mod.EXPECTED_R1_SHA256)

    def test_failure_after_commit_rolls_back_to_exact_parent(self):
        mod = load_module()
        original = mod._write_receipt

        def boom(*args, **kwargs):
            raise RuntimeError('synthetic receipt failure')

        mod._write_receipt = boom
        try:
            with self.assertRaisesRegex(RuntimeError, 'synthetic receipt failure'):
                mod.apply_revision(self.home)
        finally:
            mod._write_receipt = original

        target = self.home / Path(mod.TARGET_REL)
        self.assertEqual(sha256(target), mod.PARENT_IDENTITY_SHA256)
        for entry in MANIFEST['files']:
            path = self.home / Path(entry['target'])
            self.assertEqual(sha256(path), entry['sha256'])


if __name__ == '__main__':
    unittest.main(verbosity=2)
