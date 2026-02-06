String pluralSuffixCz(int count) {
  if (count == 1) return '';
  if (count >= 2 && count <= 4) return 'y';
  return 'ů';
}
