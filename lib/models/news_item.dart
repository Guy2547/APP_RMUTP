class NewsItem {
  final String title;
  final String subtitle;
  final String type; // 'ทุน' | 'ฝึกงาน' | 'กิจกรรม'
  final String detail;
  final String buttonLabel;
  final void Function()? onPressed;

  NewsItem({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.detail,
    required this.buttonLabel,
    this.onPressed,
  });
}
