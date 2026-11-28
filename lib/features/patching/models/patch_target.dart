enum PatchTarget {
  folkpatch,
  apatch;

  String get displayName {
    switch (this) {
      case PatchTarget.folkpatch:
        return 'FolkPatch';
      case PatchTarget.apatch:
        return 'APatch';
    }
  }

  String get directoryName {
    switch (this) {
      case PatchTarget.folkpatch:
        return 'folkpatch';
      case PatchTarget.apatch:
        return 'apatch';
    }
  }
}
