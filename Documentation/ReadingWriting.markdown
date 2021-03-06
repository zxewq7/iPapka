#Протокол передачи данных#

Ресурсы: файлы, созданные пользователем в процессе работы с системой. На текущий момент - рисование и звук.
Ресурс обладает уникальным строковым представлением (hash) и существует как значение поля. Гарантируется, что у двух разных файлов разные хеши в пределах алгоритма, использующегося при хешировании.

пример:

	{
		"audio":"63de16d627445d38674aa5600934f06e"
	}

##Чтение данных с сервера##

Каждый документ имеет две версии:

* **docVersion** - обязательная строковая версия всех безверсионных и версионных полей документа.
* **contentVersion** - обязательная строковая версия всех безверсионных полей.

считывание данных происходит в три этапа

1. чтение списка документов из следующий очередей:
	* обработанные документы: **protocol**://**hostName**/**databaseName**/archive/
	* необработанные документы: **protocol**://**hostName**/**databaseName**/inbox/
		где:

		* **protocol** - протокол работы с сервером (http или https)
		* **hostName** - имя хоста
		* **databaseName** - название базы данных. Может быть id реплики или включать в себя путь к БД.

   Обе очереди должны имеют контент в формате стандартного вывода view в формате JSON в Lotus Domino версии 7.0.2 - 8.5.x и иметь обязательную колонку **docVersion**, соответствующей **docVersion** документа. Идентификаторами документов являются UNID документа, содержащийся во view (см. документацию к Lotus Domino).
   После чтения очередей производится сравнение **docVersion** из очереди и в документах на клиенте. Если значения не совпадают или же такого документа не существует на клиенте, то такие документы должны быть заново загружены с сервера. Если на устройстве нет документов, указанных в очередях (на основании сравнения списков документов по UNID) - то такие документы должны быть удалены с клиента.

2. чтение измененных/новых документов с сервера. Тут сравнивается поле **contentVersion** локального документа и документа с сервера. При несовпадении значений этих полей все поля должны быть замещены содержимым серверного документа. URL доступа к документу: **protocol**://**hostName**/**databaseName**/document/**docId**

	Замещение файловых полей (рисование, аудио) происходит по следующему алгоритму:

	1. Если значение хеша сервера равно **null** то данный файловый ресурс должен быть уничтожен
	2. Если значения не совпадают, то локальный файл должен быть уничтожен и скачан заново.
	
	URL для скачивания документа **protocol**://**hostName**/**databaseName**/document/**docId**
	где **docId** - идентификатор (UNID) документа.

3. считывание файловых ресурсов с сервера.
	* URL доступа к рисованию к странице документа: **protocol**://**hostName**/**databaseName**/document/**docId**/file/**fileId**/page/**pageNum**/drawing
	* URL доступа к аудио комментарию документа: **protocol**://**hostName**/**databaseName**/document/**docId**/audio

##Запись данных на сервер##

Создание, удаление, изменение ресурса происходит **POST** мультипартом на  url, передаваемый в конфигурационном документе. 
Upload идет в формате **multipart/form-data** Мультипарт из двух частей: поле **json** и файл в поле, указанном в конфигурационном документе. 
В случае удаление ресурса - контент не передается.

В случае успешного завершения операции сервер должен ответить с http кодом ошибки 200 и структурой в формате JSON.
В случае неудачи сервер сервер может ответить с http кодом ошибки 

Конфликтом называется ситуация, когда передаваемая клиентом **docVersion** не совпадает со значением **docVersion** на сервере или же документ не доступен для записи.

* 404 (ресурс не существует). В этом случае все дальнейшие попытки изменения документа должны быть прекращены и документ должен быть скачан с сервера по-новой по правилам, поределенным в секции "Считывание данных с сервера"
* 500 (ошибка сервера). В случае конфликта записи сервер должен ответить **json** структурой

		{
		"code":numeric_error_code,
		"message":"human readable message"
		}

Прочие ошибки, включая 500, но с неверной структурой **json** считаются временными, и клиент должен при следующей синхронизации повторить попытку записи.

###Создание ресурса###

json -содер

Запрос:

json

	{ 
        docVersion: doc_version, 
        parent: { 
                document: doc_id, 
                file: file_id, 
                pageNum: pageNum 
                }, 
        audio: null
	}
	 
file

содержимое файла

Ответ c кодом ошибки http 200 (успех).

	{ 
        docVersion: new_doc_version, 
        parent: { 
                document: doc_id, 
                file: file_id, 
                pageNum: pageNum 
        }, 
        audio: file_hash
	} 

Реакция клиента

Клиент должен установить полю **audio** новый хеш, переданный сервером.
Клиент должен установить полю **docVersion** документа значение, переданное сервером.

###Изменение ресурса###

Запрос:

json

	{ 
        docVersion: doc_version, 
        parent: { 
                document: doc_id, 
                file: file_id, 
                pageNum: pageNum 
                }, 
        audio: file_hash
	} 
	
file

содержимое файла

Ответ c кодом ошибки http 200 (успех):

	{ 
        docVersion: new_doc_version, 
        parent: { 
                document: doc_id, 
                file: file_id, 
                pageNum: pageNum 
        }, 
        audio: new_file_hash
	} 

Реакция клиента

Клиент должен установить полю **audio** новый хеш, переданный сервером.
Клиент должен установить полю **docVersion** документа значение, переданное сервером.

###Удаление ресурса###

json

	{ 
        docVersion: doc_version, 
        parent: { 
                document: doc_id, 
                file: file_id, 
                pageNum: pageNum 
                }, 
                audio: file_hash
		}


file

не передается. 

Ответ c кодом ошибки http 200 (успех):
	{ 
        docVersion: new_doc_version, 
        parent: { 
                document: doc_id, 
                file: file_id, 
                pageNum: pageNum 
        }, 
        audio: null 
	} 

Реакция клиента

Обнулить хеш и стереть файл.
Установить полю **docVersion** документа значение, переданное сервером.

###Изменение черновика документа с резолюцией###

поле **status** должно иметь значение **draft**

Запрос:

json

	{
		"docVersion":"C32577E5:0040CB38",
		"performers":["????????????? C.M.%test%?????%C67565BD9B3D06F0C325747C0033A2FC%C32573D1003D565A","???????? ?.?.%dfsdfdsfsd%???????%C9E54951A1818D50C32575EF00466B09%C325771A0051D064","?????????? ?.?.%??????? ?????????%???????????%F73B7B2C24A68CF1C32573D8002FD17E%C32573D1003D565A"],
		"hasControl":true,
		"deadline":"20100924",
		"status":"draft",
		"text":"????????? ? ????????",
		"id":"6664E64AE72E1F3CC32577E4004EA93F"
	}

	
file

отсутствует

Ответ c кодом ошибки http 200 (успех):

	{
		"docVersion":"C32577E5:00444792",
		"contentVersion":"C32577E5:00444792"
	}

Реакция клиента

Клиент должен установить полям **docVersion** и **contentVersion** документа значения, переданные сервером.

###Принятие решения по документу с резолюцией###

поле **status** должно иметь одно из значений:

* **accepted** - у утвержденных документов
* **rejected** - у отвергнутых документов

так же дожно передаваться поле **date** - дата принятия решения

Запрос:

json

	{
		"docVersion":"C32577E5:0040CB38",
		"performers":["????????????? C.M.%test%?????%C67565BD9B3D06F0C325747C0033A2FC%C32573D1003D565A","???????? ?.?.%dfsdfdsfsd%???????%C9E54951A1818D50C32575EF00466B09%C325771A0051D064","?????????? ?.?.%??????? ?????????%???????????%F73B7B2C24A68CF1C32573D8002FD17E%C32573D1003D565A"],
		"hasControl":true,
		"deadline":"20100924",
		"status":"accepted",
		"date": "20101116T195822,00+00",
		"text":"????????? ? ????????",
		"id":"6664E64AE72E1F3CC32577E4004EA93F"
	}

	
file

отсутствует

Ответ c кодом ошибки http 200 (успех):

	{
		"docVersion":"C32577E5:00444792",
		"contentVersion":"C32577E5:00444792"
	}

Реакция клиента

Клиент должен установить полям **docVersion** и **contentVersion** документа значения, переданные сервером.

###Изменение черновика документа на подпись###

поле **status** должно иметь значение **draft**

Запрос:

json

	{
		"docVersion":"C32577E5:0040CB38",
		"status":"draft",
		"text":"????????? ? ????????",
		"id":"6664E64AE72E1F3CC32577E4004EA93F"
	}

	
file

отсутствует

Ответ c кодом ошибки http 200 (успех):

	{
		"docVersion":"C32577E5:00444792",
		"contentVersion":"C32577E5:00444792"
		"editable":true
	}

Реакция клиента

Клиент должен установить полям **docVersion**, **contentVersion** и **editable** документа значения, переданные сервером.

###Принятие решения по документу на подпись###

поле **status** должно иметь одно из значений:

* **accepted** - у утвержденных документов
* **rejected** - у отвергнутых документов

так же дожно передаваться поле **date** в формате **yyyy.MM.dd'T'HH:mm:ss'Z'Z** - дата принятия решения

Запрос:

json

	{
		"docVersion":"C32577E5:0040CB38",
		"status":"accepted",
		"date": "20101116T154043Z0000",
		"text":"????????? ? ????????",
		"id":"6664E64AE72E1F3CC32577E4004EA93F"
	}

	
file

отсутствует

Ответ c кодом ошибки http 200 (успех):

	{
		"docVersion":"C32577E5:00444792",
		"contentVersion":"C32577E5:00444792",
		"editable":true
	}

Реакция клиента

Клиент должен установить полям **docVersion**, **contentVersion** и **editable** документа значения, переданные сервером.