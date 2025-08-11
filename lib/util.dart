int countListBool(List<bool> list) {
  return list.fold(0, (count, b) => count + (b ? 1 : 0));
}
