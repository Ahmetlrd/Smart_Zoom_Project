// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get login => 'Zoom ile giriş yap';

  @override
  String get welcometext => 'Uygulamaya Hoşgeldiniz';

  @override
  String get language => 'Dil:';

  @override
  String get notifications => 'Bildirimler:';

  @override
  String get meetinglist => 'Toplantı Listesi';

  @override
  String get meetingdetails => 'Toplantı detayları';

  @override
  String get nlpsummary => 'NLP özeti';

  @override
  String get saved => 'Kayıtlı özetler';

  @override
  String get logout => 'Çıkış yap';

  @override
  String get participants => ' Katılımcılar: ';

  @override
  String get transcription => 'Transkript';

  @override
  String get summary => ' Özet(AI)';

  @override
  String get notes => ' Notlar';

  @override
  String get moreinfo => 'Daha fazla bilgi';

  @override
  String get email => 'E-posta';

  @override
  String get accounttype => 'Hesap türü: ';

  @override
  String get pleaselogin => 'Lütfen giriş yapınız';

  @override
  String get close => 'Kapat';

  @override
  String get delete => 'Sil';

  @override
  String get update => 'Güncelle';

  @override
  String get save => 'Kaydet ve Bitir';

  @override
  String get nosummaryyet => 'Henüz bir toplantı özeti oluşturulmadı.';

  @override
  String get firstnotification => 'uygulama ilk açıldı test bildirimi';

  @override
  String get testnotification => 'Bildirim izni çalışıyor!';

  @override
  String get wannasave => 'Kaydetmek istiyor musunuz?';

  @override
  String get savetofirestore => 'Bu özeti kaydedeceksiniz. Devam edilsin mi?';

  @override
  String get savedsuccesfully => 'Özet başarıyla kaydedildi.';

  @override
  String get writeprompt => 'Özete eklenecek isteğinizi yazın...';

  @override
  String get abouttodelete => 'Özeti silmek üzeresiniz';

  @override
  String get areyousuretodelete =>
      'Bu işlem geri alınamaz. Özeti silmek istediğinize emin misiniz?';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get summarydeleted => 'Özet silindi.';

  @override
  String get wannadeletemeeting => 'Toplantıyı silmek istiyor musunuz?';

  @override
  String get areyousuretocont => 'Bu işlem geri alınamaz. Devam edilsin mi?';

  @override
  String get meetingdeleted => 'Toplantı silindi.';

  @override
  String get nosummaryfound => 'Özet bulunamadı.';

  @override
  String get notranscriptfound => 'Transkript bulunamadı.';

  @override
  String get nomeetingfound => 'Hiç toplantı kaydı bulunamadı.';

  @override
  String get joinedmeeting => 'Toplantıya Katıldınız';

  @override
  String get wannapsummarize =>
      'Toplantı sonunda özet alabilmek için kaydı başlatmayı unutmayın.';

  @override
  String get summaryready => 'Zoom özeti hazır!';

  @override
  String get newmeetingsummarized => 'Yeni toplantı otomatik özetlendi.';

  @override
  String get settings => 'Ayarlar';

  @override
  String get loginonzoom => 'Zoom hesabınız üzerinden giriş yapınız.';

  @override
  String get needzoomfile => 'Zoom Klasörü Gerekli';

  @override
  String get needzoomfileexp =>
      'Lütfen Zoom klasörünü seçin. Bu klasör içinde .m4a dosyaları olmalıdır.';

  @override
  String get choosefile => 'Klasör Seç';

  @override
  String get couldnotlogin => 'Giriş yapılmadı.';

  @override
  String get searchformeeting => 'Toplantı başlığı ara...';

  @override
  String get deletemeeting => 'Toplantıyı sil';

  @override
  String get areyousuretodeletemeeting =>
      'Bu toplantı kaydını silmek istediğinizden emin misiniz?';

  @override
  String get selectameeting => 'Bir toplantı seçin.';

  @override
  String get generating => 'Oluşturuluyor...';

  @override
  String promptsecond(Object transcript, Object summary, Object userRequest) {
    return 'Aşağıdaki Zoom toplantısı transkriptlerinden yeni ve anlamlı bir özet oluştur.\n\nToplantıya ait birden fazla ses kaydından alınmış transkript parçaları bulunmaktadır. Bunları bir bütün olarak değerlendir.\n\n1. Transkripti analiz ederek en fazla 5 kelimeden oluşan, açık ve anlamlı bir başlık üret. Bu başlığı yalnızca şu formatta ver:\nTitle: Başlık Buraya (tırnak kullanma)\n\n2. Ardından, başlık satırının altına profesyonel ve bilgi odaklı bir özet yaz. Bu özet:\n- Toplantının amacı ve ana gündemini\n- Konuşan kişi veya kişileri (isim varsa belirt)\n- Tartışılan konular, sorunlar, fikirler\n- Alınan kararlar ve sonuçlar\n- Eylem maddeleri (kim, ne zaman, ne yapacak)\n- Öne çıkan ifadeleri veya önemli vurguları\nkapsamalıdır.\n\nKısa veya eksik kısımlar varsa, yalnızca verilen içerik üzerinden en iyi özetlemeyi yap. Bilgi uydurma veya tekrar etme.\n\nÖNCEKİ GPT ÖZETİ:\n$summary\n\nKULLANICININ YENİ İSTEĞİ:\n\"$userRequest\"\n\nTRANSKRİPT:\n$transcript';
  }

  @override
  String promptfirst(Object text) {
    return 'Senin görevin iki bölümlü olacak:\n\n1. **Toplantı başlığı** üret: Aşağıdaki transkripti analiz ederek en fazla 5 kelimeden oluşan, net ve anlamlı bir başlık oluştur. Bu başlığı yalnızca şu formatta döndür:\nTitle: Başlık Buraya\n\n2. **Toplantı özeti** üret: Aşağıda bir Zoom toplantısına ait birden fazla ses kaydından oluşturulmuş transkriptler bulunmaktadır. Her satır veya paragraf, farklı bir konuşma bölümünü temsil edebilir. Konular bazen dağınık gelebilir; bu yüzden parçaları anlamlı şekilde birleştirerek bütüncül ve anlaşılır bir özet oluşturman beklenmektedir.\n\nKullanıcının bu özeti okuduğunda toplantıya hiç katılmamış olsa bile tüm önemli içerikleri anlayabilmesi gerekir. Özeti profesyonel ve akademik bir üslupla, sade ve açık bir Türkçe ile oluştur.\n\nAşağıdaki başlıkları mutlaka değerlendir:\n- Toplantının amacı ve ana gündemi\n- Konuşan kişi(ler) kimdi? (isim varsa belirt)\n- Görüşülen önemli konular, sorunlar, fikirler\n- Alınan kararlar ve varılan sonuçlar\n- Eylem maddeleri (kim, ne zaman, ne yapacak)\n- Dikkat çeken ifadeler veya önemli vurgular\n\nBazı parçalar eksik veya kısa olabilir. Ancak sen tüm parçaları bir araya getirerek en anlamlı yapıyı kurmaya çalış. Bilgi eksikse bunu belirtmeden sadece mevcut içerikten faydalan.\n\n> Not: Transkript parçalara bölünmüş olsa da tüm metinleri birleştirerek tek bir toplantının özeti olarak yaz.\n\nTRANSKRİPT:\n$text';
  }

  @override
  String get userinfo => 'Kullanıcı Bilgisi';

  @override
  String get notification_preparing_title => 'Özet hazırlanıyor';

  @override
  String get notification_preparing_body =>
      'Ses dosyaları alındı, analiz başlıyor...';

  @override
  String get notification_ready_title => 'Zoom özeti hazır!';

  @override
  String get notification_ready_body => 'Yeni toplantı otomatik özetlendi.';
}
