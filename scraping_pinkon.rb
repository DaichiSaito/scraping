require 'nokogiri'
require 'open-uri'
require 'json'
require "FileUtils"

#############################ここを指定して#############################################################
# とってきたい旅館のURL
url = 'http://www.onsen-companion.jp/ashinomaki/ashinomakigrandhotel.html'
# 旅館の住所
hotelAddress = '福島県会津若松市大戸町大字芦牧下タ平１０４４'
# 旅館のgoogleMapのembedURL
googleMapEmbedUrl = '<iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3170.931586257513!2d139.91005461578618!3d37.36779564324179!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x601ffc41440fc733%3A0xa62a77c857225b89!2z6Iqm44OO54mn44Kw44Op44Oz44OJ44Ob44OG44Or!5e0!3m2!1sja!2sjp!4v1494351661000" width="600" height="450" frameborder="0" style="border:0" allowfullscreen></iframe>'
# ユーザー名。デスクトップにファイルを保存するため。
@userName = "daichisaito"
######################################################################################################

def save_image(url)
  # ready filepath
  fileName = File.basename(url)
  dirName = "/users/" + @userName + "/desktop/"
  filePath = dirName + fileName

  # create folder if not exist
  FileUtils.mkdir_p(dirName) unless FileTest.exist?(dirName)

  # write image adata
  open(filePath, 'wb') do |output|
    open(url) do |data|
      output.write(data.read)
    end
  end
end



targetFileName = "RyokanData.json"
if File.exist?(targetFileName)
  # すでにあったら何もしない
  p "すでにある"
else
  # なければファイルを作る。
  p "まだない"
  File.open(targetFileName,"w") do |file|
  file.puts("{}")
  end
end

json_file_path = targetFileName

# 読み込んで
json_data = open(json_file_path) do |io|
  JSON.load(io)
end


html = URI.parse(url).read
charset = html.charset
if charset == "iso-8859-1"
  charset = html.scan(/charset="?([^\s"]*)/i).first.join
end

doc = Nokogiri::HTML.parse(html, nil, charset)
doc.xpath('//div[@class="about"]').each do |node|
  # 旅館のキャプション
  p node.inner_text
  # 更新して
json_data['hotelCaption'] = node.inner_text

end

# 旅館名
doc.xpath('//span[@class="name"]').each do |node|
  # p node.inner_text
  hotelName = node.inner_text
  # p nameIndex = node.inner_text.slice!((path.index("\[") + 1)..path.length)
  p nameIndex = hotelName.index("\[")
  p realHotelName = hotelName.slice!(0..(nameIndex - 1))
  json_data['hotelName'] = realHotelName
end
# 住所
json_data["hotelAddress"] = hotelAddress
# アクセス
doc.xpath('//div[@id="access"]').each do |node|
  p node.inner_text
  json_data['hotelAccess'] = node.inner_text
end
# IN/OUT
doc.xpath('//div[@id="check"]').each do |node|
  p node.inner_text
  json_data['inout'] = node.inner_text
end
# 館内設備
json_data["facility"] = {
  "All" => [],
  "Furo" => [],
  "FuroIgai" => []
}
# タグの配列。これらにヒットするものがあればfacility配列に入れる。
# 0番目・・・検索ワード、1番目・・・実際の文字列、３番目・・・風呂なのか施設なのか
facilityTags = [["大浴場","大浴場","1"],["露天風呂","露天風呂","1"],["貸切","貸切風呂","1"],["宴会","宴会場","2"],["カラオケ","カラオケルーム","2"],["サウナ","サウナ","2"],["売店","売店","2"],["お食事","お食事処","2"],["会議室","会議室","2"],["スナック","スナック","2"]]

doc.xpath('//div[@id="facility"]').each do |node|
  facilityTags.each do |tag|
    if node.inner_text.include?(tag[0])
      if "1" == tag[2]
        json_data["facility"]["Furo"].push([tag[1],true])
      elsif "2" == tag[2]
        json_data["facility"]["FuroIgai"].push([tag[1],true])
      end
      json_data["facility"]["All"].push([tag[1],true])
    else
      if "1" == tag[2]
        # json_data["facility"]["Furo"].push([tag[1],false])
      elsif "2" == tag[2]
        # json_data["facility"]["FuroIgai"].push([tag[1],false])
      end
      json_data["facility"]["All"].push([tag[1],false])

    end
    # json_data["facilitys"][""]
  end
  p node.inner_text
end
# if json_data["facility"]["FuroIgai"].count == 0
#   json_data["facility"]["FuroIgai"].push("")
# end

# plansを生成
json_data["plans"] = []
# プランタイトル
docH3 = doc.xpath('//h3')
docH3.each_with_index do |node,index|
  p node.inner_text
  p kakkoIndex = node.inner_text.index("\(")
  p realPlanTitle = node.inner_text.slice!(0..(kakkoIndex - 1))
  # jsonにプラン見出しを追加。プランの数だけ
  json_data["plans"].push({
    "planMidashi" => {
      "planMidashiName" => realPlanTitle,
      "planMidashiPercentageDate" => [] #とりあえず空
    },
    "planContent" => [
      # "planName" => "",
      # "planPrice" => [

      # ]
    ],
    "list" => [
    ]


  })
end









# planTableDoc = doc.xpath('//div[@class="plan"]//table')
# p planTableDoc.count
# p "これがプランテーブルの数"

# for i in 1..planTableDoc.count
#   # テーブルのループ
#   xPathVar = '//div[@class="plan"][' + (i).to_s + ']//table'
#   xPathVarForMidashi = '//div[@class="plan"][' + (i).to_s + ']//table//tr[1]//td'
#   onePlanTableDoc = doc.xpath(xPathVar)
#   onePlanTableMidashiDoc = doc.xpath(xPathVarForMidashi)
#   p "onePlanTableDocの数は" + onePlanTableDoc.count.to_s # ちゃんとtableを一つ取ってこれてるのは間違いない。
#   p "onePlanTableMidashiDocの数は" + onePlanTableMidashiDoc.count.to_s 
#   onePlanTableDoc.each do |node|
#     # テーブル内の


#     node.xpath('tr').each_with_index do |node2,indexTR|

#       if indexTR == 0
#         # お客様 対 コンパニオン　のtrだったら無視
#       else
#         # p node2.inner_text.gsub(/(\r\n|\r|\n)/, "")
#         # p "ふふふ"

#         node2.xpath('td').each_with_index do |node3,indexTD|
#           p node3.inner_text # tdひとつひとつ。
#           if node2.xpath('td').count == indexTD + 1
#             p "最後だよ"
#             p node2.xpath('td').count
#           else
#             p "最後じゃないよ"
#             p node2.xpath('td').count
#           end
#           # json_data["plans"][i - 1]["planContent"]["planName"]
#           # p "ははは"
#         end

#       end
      
#     end

#     # p onePlanTableDoc.inner_text.gsub(/(\r\n|\r|\n)/, "")
#   end
#   xPathVarForList = '//div[@class="plan"][' + (i).to_s + ']//table//li' 
#   onePlanTableListDoc = doc.xpath(xPathVarForList)
#   onePlanTableListDoc.each_with_index do |node4,index1|
#     p "indexは" + index1.to_s #liの数

#   end

#   p onePlanTableDoc.css('tr')[0].css('td').count
#   p "ぽにょぽにょ"
# end

# プランの数を取得
planTableDoc = doc.xpath('//div[@class="plan"]//table')
p "プランの数は：" + planTableDoc.count.to_s
for planIndex in 1..planTableDoc.count

  xPathVar = '//div[@class="plan"][' + (planIndex).to_s + ']//table'
  # xPathVarForMidashi = '//div[@class="plan"][' + (i).to_s + ']//table//tr[1]//td'
  onePlanTableDoc = doc.xpath(xPathVar)
# プランの数だけ以下の処理をループ
# trをループ
  p "trの数は：" + onePlanTableDoc.css('tr').count.to_s
  for j in 1..onePlanTableDoc.css('tr').count
    if j == onePlanTableDoc.css('tr').count
      p "ここはおそらくli。なので無視"
      onePlanTableDoc.css('tr')[j-1].css('td')[0].css('li').each do |listdayo|
        p listdayo.inner_text
        json_data["plans"][planIndex-1]["list"].push(listdayo.inner_text)
      end

    elsif j == 1
      # お客様　対　コンパニオンとか金曜日・日祭日とか
      p "ここはおそらく曜日とかが書いてあるtr"
      p onePlanTableDoc.css('tr')[j-1].css('td').inner_text


      for k in 1..onePlanTableDoc.css('tr')[j - 1].css('td').count
        
        if k == 1
          # お客様　対　コンパニオンのときはphpに書いてあるから何もしない
          
        else
          tdText = onePlanTableDoc.css('tr')[j - 1].css('td')[k-1].inner_text
          json_data["plans"][planIndex-1]["planMidashi"]["planMidashiPercentageDate"].push(tdText)

        end
      end










      




    else

      json_data["plans"][planIndex - 1]["planContent"].push({
          "planName" => "",
          "planPrice" => []
          })
      p "ここはおそらくtd"
      # tdをループ
      p "tdの数は：" + onePlanTableDoc.css('tr')[j - 1].css('td').count.to_s
      for k in 1..onePlanTableDoc.css('tr')[j - 1].css('td').count
        
        if k == 1
          #kが1の時はplanNameにいれる
          p "plansの数は：" + json_data["plans"].count.to_s
          p "kが1のときつまりtdの一つ目の時つまり4:1とかのとき"
          tdText = onePlanTableDoc.css('tr')[j - 1].css('td')[k-1].inner_text
          p tdText
          p "jは：" + j.to_s
          p "planIndexは：" + planIndex.to_s
          p 'json_data["plans"][planIndex - 1]["planContent"]' + json_data["plans"][planIndex - 1]["planContent"].count.to_s
          # tdText.tr!("０-９", "0-9")
          # p tdText.tr!("０-９", "0-9").scan(/\d+/)[1]
          hankakuTdText = tdText.tr!("０-９", "0-9")
          hankaku1 = hankakuTdText.scan(/\d+/)[0]
          hankaku2 = hankakuTdText.scan(/\d+/)[1]
          # p tdText.scan(/\d+/)[0]
          # p tdText.scan(/\d+/)[1]
          json_data["plans"][planIndex - 1]["planContent"][j-2]["planName"] = hankaku1 + "：" + hankaku2
          
        else
          #それ以外の時はplanPriceにpush
          # priceの時だと思う。
          tdText = onePlanTableDoc.css('tr')[j - 1].css('td')[k-1].inner_text
          p tdText
          json_data["plans"][planIndex - 1]["planContent"][j-2]["planPrice"].push(tdText)

        end
      end
    end

  end
  
end




















# # プラン
# # p count(doc.xpath('//div[@class="plan"]'))
# trTexts = []
# # jsonTest = []
# midashiDoc = doc.xpath('//div[@class="plan"]//table//tr[1]//td')
# p midashiDoc.count
# p "これが見出しの数です。"
# midashiPerPlan = (midashiDoc.count / docH3.count)
# p midashiPerPlan
# planIndex = 0
# doc.xpath('//div[@class="plan"]//table//tr[1]//td').each_with_index do |node, index|
#   # 見出し数をプラン数で割れば、1プランあたりの見出し数がわかる
  
#   # p "1プランあたりの見出し数は" + midashiPerPlan
#   innerText = node.inner_text.gsub(/(\r\n|\r|\n)/, "")
#   p innerText
#   p planIndex
#   p "番目のプランに追加します"
#   if innerText.include?("お客様")
#     # お客様　対　コンパニオン　の時は追加しない。
#   else
#     json_data["plans"][planIndex]["planMidashi"]["planMidashiPercentageDate"].push(innerText)
#   end
  
#   if ((index + 1)  % midashiPerPlan == 0) 
#     # p "割り切れました"
#     planIndex = planIndex + 1
#   else
#     # p "割り切れません"
#     # 何もしない
#   end
  
# end



# 画像のパス
doc.xpath('//div[@class="photo"]').each do |node|
  path = node.css('img').attribute('src').value
  hotelImage = path.slice!((path.rindex("\/") + 1)..path.length)
  p hotelImage
  json_data["hotelImage"] = hotelImage

end
# 画像のキャプション
imageCaptions = []
imagePaths = []
downloadURL = ""
doc.xpath('//div[@class="image"]').each do |node|
  p node.inner_text
  imageCaptions.push(node.inner_text)

  path = node.css('img').attribute('src').value
  imagePath = path.slice!((path.rindex("\/") + 1)..path.length)

  downloadURL = path.slice!((path.index("\/") + 1)..path.length)
  # downloadURLにはphoto/地名/が入ってる
  save_image("http://www.onsen-companion.jp/" + downloadURL + imagePath)
  imagePaths.push(imagePath)

end
p "http://www.onsen-companion.jp/" + downloadURL + json_data["hotelImage"]
save_image("http://www.onsen-companion.jp/" + downloadURL + json_data["hotelImage"])
json_data["imageList"] = {"caption":[]}
json_data["imageList"] = {"path":[]}
json_data["imageList"]["caption"] = imageCaptions
json_data["imageList"]["path"] = imagePaths
# p imageCaptions
# embedMapURL
embedHtml = Nokogiri::HTML.parse(googleMapEmbedUrl, nil, charset)
embedHtml.xpath('//iframe').each do |node|
  # p node.attribute('src').value
  json_data["embedMapURL"] = node.attribute('src').value
end


# 保存する
open(json_file_path, 'w') do |io|
  JSON.dump(json_data, io)
end


# google_embed_url = "https://www.google.com/maps/embed/v1/place?key=AIzaSyCt1mxQTEChdmJS8lyy1k7SHE5NznLorYo&q=%E6%9D%B1%E4%BA%AC%E9%A7%85&zoom=15"
# 