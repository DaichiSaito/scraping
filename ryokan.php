<?php


if (is_uploaded_file($_FILES["upfile"]["tmp_name"])) {
  if (move_uploaded_file($_FILES["upfile"]["tmp_name"], "files/" . "ryokanJson.json")) {
    chmod("files/" . $_FILES["upfile"]["name"], 0644);
    // echo $_FILES["upfile"]["name"] . "をアップロードしました。";
  } else {
    echo "ファイルをアップロードできません。";
    return;
  }
} else {
  echo "ファイルが選択されていません。";
  return;
}
$url = "http://localhost:8888/Hotel/files/ryokanJson.json";
$json = file_get_contents($url);
$json = mb_convert_encoding($json, 'UTF8', 'ASCII,JIS,UTF-8,EUC-JP,SJIS-WIN');
$arr = json_decode($json,true);
?>
<!DOCTYPE html>
<head>
<meta charset = “UTF-8”>
<title>フォームからデータを受け取る</title>
</head>
<body>
<div class="hotel-information clearfix">
	<div class="hotel-information-left">
		<h2 class="chimei">東北・福島・芦ノ牧</h2>
		<img src="http://p-companion.com/wp-content/uploads/2017/05/<?php echo $arr["hotelImage"] ?>" alt="温泉写真" width="100%" />
		<p class="stars"></p>
	</div>
	<div class="hotel-information-right">
	
		<h2 class="hotel-name"><?php echo $arr["hotelName"] ?></h2>
	
		<p>住所：　<?php echo $arr["hotelAddress"] ?><br />
			アクセス：　<?php echo $arr["hotelAccess"] ?></p>
			<p>館内設備</p>

			<ul class="icon-lists">
			
				<?php $tagCount = count($arr["facility"]["All"]) ?>
				<?php for ($i = 0; $i < $tagCount; $i++) : ?>

					<?php if ($arr["facility"]["All"][$i][1]) : ?>
						
						
						<li class="icon valid"><?php echo $arr["facility"]["All"][$i][0] ?></li>
					
					<?php  else : ?>
						
						
						<li class="icon"><?php echo $arr["facility"]["All"][$i][0] ?></li>

					<?php endif; ?>
				<?php endfor; ?>
			</ul>
		</div>
	</div>

	<h2 class="conversion"><a href="http://p-companion.com/contact" />お問い合わせ</a></h2>

	<!--ここがタブ-->
	<ul id="tab">
		<li class="selected"><a href="#tab1">基本情報</a></li>
		<li><a href="#tab2">プラン</a></li>
		<li><a href="#tab3">フォト</a></li>
		<li><a href="#tab4">口コミ</a></li>
		<li><a href="#tab5">マップ</a></li>

	</ul>
	<div id="tabContents">
		<div id="tab1">
			<p><?php echo $arr["hotelCaption"] ?></p>

			<dl class="basic-information">
				<dt>住所</dt>
				<dd><?php echo $arr["hotelAddress"] ?></dd>
				<dt>アクセス</dt>
				<dd><?php echo $arr["hotelAccess"] ?></dd>
				<dt>風呂</dt>
				<dd><?php foreach ($arr["facility"]["Furo"] as $value) {if ($value === end($arr["facility"]["Furo"])) {echo $value[0];} else {echo $value[0] . "・";}}?></dd>
				<dt>施設</dt>
				<dd><?php foreach ($arr["facility"]["FuroIgai"] as $value) {if ($value === end($arr["facility"]["FuroIgai"])) {echo $value[0];} else {echo $value[0] . "・";}}?></dd>
				<dt>IN／OUT</dt>
				<dd><?php echo $arr["inout"] ?></dd>
				<dt>駐車場</dt>
				<dd>有り</dd>
				<dt>送迎</dt>
				<dd>有り</dd>
			</dl>

			<!--<p class="message"></p>-->

		</div>
		<div id="tab2">
			<p class="plan">コンパニオンプラン一覧</p>
			<?php
				// echo $arr["plans"][0]["planMidashi"]["planMidashiName"];
				$count = count($arr["plans"]);
				$index = 0
				?>
				<?php while ($index < $count) : ?>
					
			<h3 class="companion-plan"><?php echo $arr["plans"][$index]["planMidashi"]["planMidashiName"] ?></h3>
			<table class="plan-price" width="100%" border="0" cellspacing="3" cellpadding="5">
				<tr>
					<td class="table-pink">お客様：コンパニオン</td>
					<?php $planMidashiCount = count($arr["plans"][$index]["planMidashi"]["planMidashiPercentageDate"]);
					// echo $planMidashiCount;
						$midashiIndex = 0;
					?>
					<?php while ($midashiIndex < $planMidashiCount) : ?>
						<td class="table-pink"><?php echo $arr["plans"][$index]["planMidashi"]["planMidashiPercentageDate"][$midashiIndex] ?></td>
						
					<?php $midashiIndex++; ?>
					<?php endwhile ?>
					
				</tr>
				<?php $thisPlanContentCount = count($arr["plans"][$index]["planContent"]);
					$thisPlanContentIndex = 0;
					while ($thisPlanContentIndex < $thisPlanContentCount) : ?>

					<tr>
						<td class="table-pink"><?php echo $arr["plans"][$index]["planContent"][$thisPlanContentIndex]["planName"] ?></td>
						<?php $planPriceCount = count($arr["plans"][$index]["planContent"][$thisPlanContentIndex]["planPrice"]); ?>
						
						<?php for ($i = 0; $i < $planPriceCount; $i++) : ?>
							<td class="price"><?php echo $arr["plans"][$index]["planContent"][$thisPlanContentIndex]["planPrice"][$i] ?></td>	
						<?php endfor; ?>
					</tr>
					
					
					<?php $thisPlanContentIndex++;
					endwhile ?>
				</table>
				<ul class="plan-detail">
				<?php $planDetailCount = count($arr["plans"][$index]["list"]);
					for ($i = 0; $i < $planDetailCount; $i++) : ?>
				
					<li><?php echo $arr["plans"][$index]["list"][$i] ?></li>
				
				<?php endfor; ?>
				</ul>

				
				<?php $index++; ?>
			<?php endwhile; ?>

			</div>
			<div id="tab3">
				<p class="photo">写真一覧</p>
				<ul class="photo-lists">
				<?php $imageListCount = count($arr["imageList"]["path"]);
				for ($i = 0; $i < $imageListCount; $i++) : ?>
					<li><img src="http://p-companion.com/wp-content/uploads/2017/05/<?php echo $arr["imageList"]["path"][$i] ?>"><p><?php echo $arr["imageList"]["caption"][$i] ?></p></li>
				<?php endfor; ?>
				</ul>
			</div>
			<div id="tab4">
				<p class="kuchikomi">クチコミ</p>
			</div>
			<div id="tab5">
				<p class="map">マップ</p>
				<iframe src="<?php echo $arr["embedMapURL"] ?>"   width="100%" height="400" frameborder="0" style="border:0" allowfullscreen></iframe>
			</div>
		</div>
</body>
</html>


