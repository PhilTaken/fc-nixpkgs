{ lib
, buildPythonPackage
, fetchPypi
, aiohttp
, requests
, fastapi
, pythonOlder
}:

buildPythonPackage rec {
  pname = "pyTelegramBotAPI";
  version = "4.7.0";
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-sVu518B+PDSpW6MhYtNWkPpwuT471VfGuDDtpL7Mo/U=";
  };

  propagatedBuildInputs = [
    aiohttp
    requests
    fastapi
  ];

  pythonImportsCheck = [
    "telebot"
  ];

  meta = with lib; {
    homepage = "https://github.com/eternnoir/pyTelegramBotAPI";
    description = "A simple, but extensible Python implementation for the Telegram Bot API";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ das_j ];
  };
}
