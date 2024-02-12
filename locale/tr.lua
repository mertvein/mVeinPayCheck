local Translations = {
    error = {
         failed_to_open_menu = 'Menü Açılamadı',
         withdraw_failed = 'Para Çekme İşlemi Başarısız',
         bad_input = 'Hatalı Sayı',
         money_amount_more_than_zero = "Para Miktarı 0'dan büyük olmalıdır",
         can_not_withdraw_much = 'Bu kadar para çekemezsin!'
    },
    success = {
         successful_withdraw = 'Maaş çekildi : '
    },
    info = {
         no_money_in_account = 'Hesabında bu kadar para yok!'
    },
    mail = {

    },
    menu = {
         back = 'Geri',
         leave = 'Çık',

         -- qb-target
         qb_target_label = 'Maaş İşlemleri',

         -- qb-input / withdraw amount
         withdraw_amount = {
              header = 'Para Miktarı',
              submitText = 'Çek',
              textbox = 'Maksimum: $'
         },
         -- withdraw_menu
         withdraw_menu = {
              header = 'Banka (Maaş Çeki)',
              account_Information = 'Hesap Bilgileri',
              withdraw_all = 'Tümünü Çek',
              withdraw_amount = 'Para Çekme Miktarı',
              transaction_history = 'İşlem Geçmişi',
              money_string = 'Birikmiş Paran: %s$'
         },

         -- logs_menu
         logs_menu = {
              paycheck_logs = 'Maaş Kayıtları',
              before = 'Öncesi : %s$',
              after = 'Sonrası : %s$',
              recived = 'Çekilen Para %s$',
              withdraw = 'Geri Çekilen %s$',
              to = ' | Kişiye: ',
              from = ' | Çeken Kişi: '
         }
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
