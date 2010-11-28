 userscripts.org を更新するための Mechanize スクリプト
=======================================================

perl の WWW::Mechanize を用いて、userscripts.org のスクリプトを更新します。
CLI は今後変更する可能性がありますが、現状、

    post-userscripts-org.pl <SCRIPT ID> <スクリプトのファイル名>

です。

git の post-commit とかの hook に設定してもいいかも。


 必要なもの
------------

  - WWW::Mechanize
  - JSON::Syck

 前準備
--------

ホームディレクトリに .accounts.json の名前で、以下のように json の形で
アカウント情報を記述してください。

    {
      "userscripts.org" : {
        "<your email address>" : {
          "password" : "<your password>"
        }
      }
    }

このファイルは、パーミッションを 0600 に設定するなどして、簡単には見られない
ようにして下さいね。

ああ、ホームディレクトリにアカウント情報を JSON の形で持っておくと、
いろんな場面で使えるんで、オイラはそうしてます。
