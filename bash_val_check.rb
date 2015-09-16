# 対象ディレクトリ
DIR = "/Users/hoshito/ruby/test"

# 安全レベル
# ERROR : 変数宣言がされていない
# WARN : 変数宣言と変数使用が 異なるファイル
# SAFE : 変数宣言と変数使用が 同じファイル and 変数宣言が先
# ELSE : それ以外
ERROR = "ERROR"
WARN = "WARN"
SAFE = "SAFE"
ELSE = "???"

# val_use = { 変数名 => [ { use_file => 使用箇所, use_line_num => 使用行} ] }
# val_sengen = { 変数名 => [ { sengen_file => 宣言箇所, sengen_line_num => 宣言行} ] }
val_sengen = {}
val_use = {}

# ファイルを走査して変数使用を探す
# ファイルでeach
Dir.glob("#{DIR}/**/*.sh").each do |file_name|
  next unless File.ftype(file_name) == "file"
  file = File.open(file_name)
  num = 0
  # 行でeach
  file.each_line do |line|
    num += 1
    # 単語でeach
    line.split(/ +/).each do |word|
      # 使用 ${VAL} or $VAL の形式
      md = word.match(/\$\{?([A-Za-z_]+)\}?/)
      unless md.nil? then
        val = md[1]
        val_use[val] = [] unless val_use.has_key?(val)
        val_use[val] << { "use_file" => file_name, "use_line_num" => num }
      end
      # 宣言 VAL= の形式
      md = word.match(/([A-Za-z_]+)=/)
      unless md.nil? then
        val = md[1]
        val_sengen[val] = [] unless val_sengen.has_key?(val)
        val_sengen[val] << { "sengen_file" => file_name, "sengen_line_num" => num }
      end
    end
  end
end

# 使用変数を回して安全性をチェック
val_use.each_key do |key|
  puts "#{key}: "
  val_use[key].each do |use|
    unless val_sengen.has_key?(key)
      puts "  #{ERROR} : #{use}"
    else
      val_sengen[key].each do |sengen|
        if use["use_file"] != sengen["sengen_file"]
          puts "  #{WARN} : #{sengen}, #{use}"
        elsif use["use_line_num"] > sengen["sengen_line_num"]
          puts "  #{SAFE} : #{sengen}, #{use}"
        else
          puts "  #{ELSE} : #{sengen}, #{use}"
        end
      end
    end
  end
end

