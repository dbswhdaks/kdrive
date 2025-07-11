echo "자동화 스크립트 목록입니다."
echo
echo "[1] CodegenLoader 생성"
echo "[2] LocaleKeys 생성"
echo
read -p "Run: " selection

case $selection in

    1)
    echo "CodegenLoader 생성"
    flutter pub run easy_localization:generate -S assets/translations
    ;;

    2)
    echo "LocaleKeys 생성"
    flutter pub run easy_localization:generate -f keys -o locale_keys.g.dart -S assets/translations
    ;;


    *)
    echo "Unknown command!!"
    ;;

esac