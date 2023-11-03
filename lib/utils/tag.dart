class Tag {
  List<String> getTrimmedList(String text) {
    List<String> tagList = text.split('#');
    List<String> ret = tagList.map((value) {
      return value.trim();
    }).toList();
    ret.removeAt(0);
    return ret;
  }
}
