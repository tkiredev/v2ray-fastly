#!/bin/bash
global_token=""

URL_API="http://api.kiredev.shop"

IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1)

_banner () {
  clear
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo -e "               AUTH CLIENT  |  @kiredev "
  echo -e "\033[0;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
}

_auth () {
  read -p "[~] KEY: " key

  res=(`curl --silent "$URL_API/client/auth" -d "_key=$key" -H "X-Parse-id: 3028377422"`)

  [[ `echo -e $res | grep -E -i -w "invalid_request"` ]] && echo -e "\033[31mHay un error en la solicitud\033[0m"

  if [[ -z $key ]]; then
    clear
    echo -e "\033[31mPorfavor ingrese una key\033[0m\n"
    _auth
  elif [[ `echo -e $res | grep -E -i -w "invalid_grant"` ]]; then
    clear
    echo -e "\033[31mSu Key es incorrecta. vuelva a intentarlo /o compre una nueva \033[0m\n"
    _auth
  elif [[ `echo -e $res | grep -E -i -w "used_key"` ]]; then
    clear
    echo -e "\033[31mEsta key ya fue utilizada, vuelva a intentarlo con otra. \033[0m\n"
    _auth
  fi

  if [[ `echo -e $res | grep -E -i -w "_token"` ]]; then
    clear
    echo -e "\033[32mKey verificada correctamente\033[0m"

    global_token=$(echo "$res" | grep -oP '"_token":"*\K[^"]*')

    if [[ -f "_access.key" ]];then
      rm _access.key
    fi
    echo $global_token >> _access.key
  fi

}

iv2ray () {
  clear && _banner
  #Verify status server
  source <( curl --silent "$URL_API/server/status") > /dev/null 2>&1

  #[ ! -z $STATUS ] && echo -e "Server offline" && return 0

  echo -e "[!] ingrese su key para activar su cuenta y continuar con la instalacion\n"
  
  _auth
  [[ ! -f "_access.key" ]] && {
    clear
    echo -e "[*] instalacion truncada"
    echo -e "[!] Este problema es provocado en el servidor; contacta a soporte.\n"
    return 0
  }

  #download package
  source <(curl --silent "$URL_API/v2ray/install/$global_token") > /dev/null 2>&1
}

__init () {
  #root sistem
  [[ "$(whoami)" != "root" ]] && echo -e "Se nesecita root para correr este script" && return 0
  iv2ray
}

__init