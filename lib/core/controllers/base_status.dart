enum BaseStatus {
  initial("initial"),
  loading("loading"),
  empty("empty"),
  error("error"),
  success("success");

  final String title;

  const BaseStatus(this.title);
}
