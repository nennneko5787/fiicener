/*
void main() {
  var name = ReportTypes.harassment.displayName;
  print(name);
}
*/

enum ReportTypes{
  harassment('嫌がらせ、いじめ', '侮辱的発言。望ましくない成人向けコンテンツや露骨な性的対象化。特定の人物への嫌がらせ。'),
  discrimination('差別的または攻撃的な内容', '人種、性差別主義的なコンテンツ。差別を助長するコンテンツ。人格否定。'),
  misinformation('誤った有害な情報', '誤解を招くコンテンツまたは虚偽が含まれたコンテンツで、深刻な危害を及ぼす可能性があるもの。'),
  violence('暴力的な発言', '強烈な身体的脅迫、危害の願望。暴力の賛美。暴力を助長するコンテンツ。'),
  privacy('プライバシーの侵害', '個人情報を公開している。個人情報を公開すると脅迫している。合意のない私的な画像を公開している。'),
  spoofing('なりすまし', '本人でないことを明示していない者による、他人になりすましての発言、活動。'),
  suicide('自殺や自傷行為', '自殺、自傷行為を助長、推奨、指示したり、策略を共有したりしている。'),
  spam('スパムまたは誤解を招く内容', '情報の過度な誇張。悪意のあるリンクを含むコンテンツ。ハッシュタグの乱用。'),
  sensitive('センシティブまたは不快感のある内容', '不当なグロテスク表現。成人のヌードと性行為。獣姦と屍姦。'),
  ;
  
  const ReportTypes(this.displayName, this.description);

  final String displayName;
  final String description;
}
