#!/usr/bin/env python3
"""Apply and verify the single-file GEAC X1 -> X1-R1 identity/provenance revision."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

REVISION_ID = "GEAC-2026-08-15-X1-R1-IDENTITY-PROVENANCE-BOUNDARY"
PARENT_REVISION = "X1"
REVISION = "X1-R1"
TARGET_REL = ".gemini/antigravity-cli/skills/geac-x1-engineering-identity.md"
PARENT_IDENTITY_SHA256 = "f32177a8012cba43ec466bf55cac1608bf1aafd37e433b0a899ce91d63fd67fa"
EXPECTED_R1_SHA256 = "0dd2355ee3bd513bd6bb155b48f0ba9b7be747ca3d7f1834012ea3354aea2f50"

PARENT_MANAGED_SHA256 = {
    ".gemini/GEMINI.md": "4561400a6215fc8ebc3f003185269b00ebb0b0eacba81c97529195051276087e",
    ".gemini/antigravity-cli/skills/geac-x1-engineering-evidence.md": "b3dc748d2c5d7bdd757cd05009aa45585d313b2fac90a74d975e8e98cf097908",
    ".gemini/antigravity-cli/skills/geac-x1-engineering-transitions.md": "83d2b6a863414a8fba4efabad9196c3d9c9a58ff27f0f43249beb2b3f985978f",
    ".gemini/antigravity-cli/skills/geac-x1-engineering-testing.md": "339806d69e0b93de7de4371b3891ec5f2b0dcd91e4cdd518a46a27a188f8f704",
    TARGET_REL: PARENT_IDENTITY_SHA256,
    ".gemini/antigravity-cli/skills/geac-x1-engineering-criteria.md": "886c2888dee332efd79c9b53693dd81dbc14b0b5230a0563b93dd89f07622b5e",
    ".gemini/antigravity-cli/skills/geac-x1-engineering-authority.md": "3d712609c54ad57aad4db06c9e24cd8630b369256860d169f30f302edff2c986",
    ".gemini/antigravity-cli/skills/geac-x1-engineering-history.md": "3c041b96f20a385ad60f3de5020a3ff20342ef3cd2148f0d9857e4fccffb113f",
    ".gemini/antigravity-cli/skills/geac-x1-engineering-reporting.md": "cb210920d7f909f2f157a1e0e3726234b66e0c725147bf336c173cb6736005ff",
}

ANCHOR = b"`SAME_METADATA(A,B) -/-> SAME_ARTIFACT(A,B)`  \n"
REPLACEMENT = ANCHOR + (
    b"`SAME_METADATA(A,B) -/-> ACQUISITION_PROVENANCE(B)`  \n"
    b"`NEAR_TIMESTAMP(A,B) -/-> ACQUISITION_PROVENANCE(B)`  \n\n"
    b"Combinations of name, size, path, timestamp, or other metadata do not establish a copy, transfer, staging, derivation, lineage, generation, or acquisition event. "
    b"Without event-binding evidence, report only the metadata relation actually established and keep the provenance relation `NOT_ESTABLISHED`. "
    b"Do not introduce an unsupplied provenance event merely as a compatibility explanation for the metadata.\n\n"
)


def _sha256_bytes(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def _managed_paths(home: Path) -> dict[str, Path]:
    return {rel: home / Path(rel) for rel in PARENT_MANAGED_SHA256}


def _snapshot(home: Path) -> dict[str, str]:
    snapshot: dict[str, str] = {}
    for rel, path in _managed_paths(home).items():
        if not path.is_file():
            raise RuntimeError(f"PARENT_STATE_MISMATCH: missing managed file: {rel}")
        snapshot[rel] = _sha256_file(path)
    return snapshot


def _verify_parent_or_r1_state(home: Path) -> tuple[str, dict[str, str]]:
    snapshot = _snapshot(home)
    mismatches = []
    for rel, expected in PARENT_MANAGED_SHA256.items():
        actual = snapshot[rel]
        if rel == TARGET_REL and actual == EXPECTED_R1_SHA256:
            continue
        if actual != expected:
            mismatches.append(f"{rel}: expected={expected} actual={actual}")

    if mismatches:
        raise RuntimeError("PARENT_STATE_MISMATCH:\n  " + "\n  ".join(mismatches))

    target_hash = snapshot[TARGET_REL]
    if target_hash == EXPECTED_R1_SHA256:
        for rel, expected in PARENT_MANAGED_SHA256.items():
            if rel != TARGET_REL and snapshot[rel] != expected:
                raise RuntimeError(f"PARENT_STATE_MISMATCH: non-target changed after R1: {rel}")
        return "R1", snapshot

    if target_hash != PARENT_IDENTITY_SHA256:
        raise RuntimeError(
            f"PARENT_STATE_MISMATCH: identity target expected={PARENT_IDENTITY_SHA256} actual={target_hash}"
        )
    return "X1", snapshot


def _build_r1_bytes(parent_bytes: bytes) -> bytes:
    if _sha256_bytes(parent_bytes) != PARENT_IDENTITY_SHA256:
        raise RuntimeError("PARENT_STATE_MISMATCH: target bytes are not the frozen X1 identity skill")
    if parent_bytes.count(ANCHOR) != 1:
        raise RuntimeError(f"PATCH_ANCHOR_MISMATCH: expected exactly one anchor, found {parent_bytes.count(ANCHOR)}")
    if b"ACQUISITION_PROVENANCE(B)" in parent_bytes:
        raise RuntimeError("PATCH_PRECONDITION_MISMATCH: R1 provenance marker already present in parent bytes")
    revised = parent_bytes.replace(ANCHOR, REPLACEMENT, 1)
    actual = _sha256_bytes(revised)
    if actual != EXPECTED_R1_SHA256:
        raise RuntimeError(f"PATCH_OUTPUT_HASH_MISMATCH: expected={EXPECTED_R1_SHA256} actual={actual}")
    return revised


def _utc_timestamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")


def _atomic_write_bytes(path: Path, data: bytes) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp_name = tempfile.mkstemp(prefix=path.name + ".tmp-", dir=str(path.parent))
    temp_path = Path(temp_name)
    try:
        with os.fdopen(fd, "wb") as f:
            f.write(data)
            f.flush()
            os.fsync(f.fileno())
        os.replace(temp_path, path)
    finally:
        if temp_path.exists():
            temp_path.unlink()


def _write_receipt(path: Path, receipt: dict[str, Any]) -> None:
    data = (json.dumps(receipt, indent=2, sort_keys=True) + "\n").encode("utf-8")
    _atomic_write_bytes(path, data)


def _verify_exact_r1(home: Path) -> dict[str, str]:
    snapshot = _snapshot(home)
    failures = []
    for rel, parent_hash in PARENT_MANAGED_SHA256.items():
        expected = EXPECTED_R1_SHA256 if rel == TARGET_REL else parent_hash
        if snapshot[rel] != expected:
            failures.append(f"{rel}: expected={expected} actual={snapshot[rel]}")
    if failures:
        raise RuntimeError("POSTCONDITION_FAILED:\n  " + "\n  ".join(failures))
    return snapshot


def _verify_exact_parent(home: Path) -> None:
    snapshot = _snapshot(home)
    failures = [
        f"{rel}: expected={expected} actual={snapshot[rel]}"
        for rel, expected in PARENT_MANAGED_SHA256.items()
        if snapshot[rel] != expected
    ]
    if failures:
        raise RuntimeError("ROLLBACK_VERIFICATION_FAILED:\n  " + "\n  ".join(failures))


def apply_revision(home: Path | str | None = None) -> dict[str, Any]:
    home_path = Path.home() if home is None else Path(home)
    home_path = home_path.expanduser().resolve()

    state, pre_snapshot = _verify_parent_or_r1_state(home_path)
    if state == "R1":
        return {
            "status": "ALREADY_APPLIED_AND_VERIFIED",
            "revision_id": REVISION_ID,
            "revision": REVISION,
            "target": str(home_path / Path(TARGET_REL)),
            "sha256": EXPECTED_R1_SHA256,
        }

    target = home_path / Path(TARGET_REL)
    parent_bytes = target.read_bytes()
    revised_bytes = _build_r1_bytes(parent_bytes)

    stamp = _utc_timestamp()
    backup_dir = home_path / ".gemini" / "geac-backups" / "X1-R1" / stamp
    backup_path = backup_dir / "geac-x1-engineering-identity.md"
    receipt_dir = home_path / ".gemini" / "geac-revisions" / "X1-R1"
    receipt_path = receipt_dir / f"{stamp}.json"

    backup_dir.mkdir(parents=True, exist_ok=False)
    shutil.copyfile(target, backup_path)
    if _sha256_file(backup_path) != PARENT_IDENTITY_SHA256:
        raise RuntimeError("BACKUP_VERIFICATION_FAILED: copied parent identity skill hash does not match X1")

    committed = False
    try:
        _atomic_write_bytes(target, revised_bytes)
        committed = True
        post_snapshot = _verify_exact_r1(home_path)

        receipt = {
            "record_type": "GEAC_LOCAL_REVISION_RECEIPT",
            "revision_id": REVISION_ID,
            "parent_revision": PARENT_REVISION,
            "revision": REVISION,
            "created_at_utc": datetime.now(timezone.utc).isoformat(),
            "home": str(home_path),
            "changed_files": [TARGET_REL],
            "backup_path": str(backup_path),
            "pre_sha256": pre_snapshot,
            "post_sha256": post_snapshot,
            "expected_parent_identity_sha256": PARENT_IDENTITY_SHA256,
            "expected_r1_identity_sha256": EXPECTED_R1_SHA256,
            "verification": "APPLIED_AND_BYTE_VERIFIED",
        }
        _write_receipt(receipt_path, receipt)

        return {
            "status": "APPLIED_AND_VERIFIED",
            "revision_id": REVISION_ID,
            "revision": REVISION,
            "target": str(target),
            "old_sha256": PARENT_IDENTITY_SHA256,
            "new_sha256": EXPECTED_R1_SHA256,
            "backup_path": str(backup_path),
            "receipt_path": str(receipt_path),
        }
    except Exception:
        if committed:
            try:
                shutil.copyfile(backup_path, target)
                _verify_exact_parent(home_path)
            except Exception as rollback_error:
                raise RuntimeError(
                    "ROLLBACK_FAILED: X1-R1 application failed and exact X1 parent state could not be re-established: "
                    + str(rollback_error)
                ) from rollback_error
        raise


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Apply the single-file GEAC X1 -> X1-R1 identity/provenance boundary revision."
    )
    parser.add_argument(
        "--home",
        type=Path,
        default=None,
        help="Override the user home directory. Intended for controlled testing; omit for normal use.",
    )
    args = parser.parse_args(argv)

    try:
        result = apply_revision(args.home)
    except Exception as exc:
        print(f"X1-R1 FAILED: {exc}", file=sys.stderr)
        return 1

    print(json.dumps(result, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
