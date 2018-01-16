type Account::Sshkey = Struct[{
  key               => Pattern[/^[A-Za-z0-9+\/]+={0,2}$/],
  type              => String,
  Optional[options] => Variant[String, Array[String]],
  Optional[target]  => Account::Path,
}]
