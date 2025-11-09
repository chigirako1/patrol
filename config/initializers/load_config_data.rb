
# イニシャライザでrequireすると開発環境でも再読込されなくなるので面倒
#require Rails.root.join('app', 'models', 'concerns', 'Util.rb')
#require Rails.root.join('app', 'models', 'concerns', 'twt.rb')

module AppData
    # ここにファイルの読み込みロジックを記述
    #FILE_CONTENT = File.read(Rails.root.join('config', 'my_data.txt')).freeze

    # JSONやYAMLならパースして保持
    #CONFIG_HASH = YAML.load_file(Rails.root.join('config', 'settings.yml')).freeze


    #FILESIZE_HASH = Twt::init_pic_infos().freeze
end
