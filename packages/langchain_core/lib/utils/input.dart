const _kTextColorMapping = {
  'blue': '36;1',
  'yellow': '33;1',
  'pink': '38;5;200',
  'green': '32;1',
  'red': '31;1',
};
///Get mapping for items to a support color.
Map<String, String> getColorMapping(final List<String> items,
    {final List? excludedColors,}) {
  var colors = _kTextColorMapping.keys.toList();
  if (excludedColors != null) {
    colors = colors.where((final c) => !excludedColors.contains(c)).toList();
  }
  final colorMapping = <String, String>{};
  for (var i = 0; i < items.length; i++) {
    colorMapping[items[i]] = colors[i % colors.length];
  }
  return colorMapping;
}
