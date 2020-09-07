﻿Функция ЛичнаяВременнаяПапка(ПовтИсп = Истина) Экспорт
	Если ПовтИсп = Истина Тогда
		Возврат А1Э_ПовторноеИспользование.РезультатФункции(ИмяМодуля() + ".ЛичнаяВременнаяПапка", Ложь);
	КонецЕсли;
	WSH = Новый COMОбъект("Wscript.shell");
	Путь = "" + WSH.ExpandEnvironmentStrings("%temp%");
	Путь = А1Э_Строки.ЗавершитьПодстрокой(Путь, "\");
	Возврат Путь;
КонецФункции

Функция ПолучитьПутьКФайлу(Файл, Расширение = "") Экспорт
	Если ТипЗнч(Файл) = Тип("Строка") Тогда
		Возврат Файл;
	ИначеЕсли ТипЗнч(Файл) = Тип("ДвоичныеДанные") Тогда
		Возврат ПоместитьФайлВоВременнуюПапку(Файл, Расширение);
	Иначе
		А1Э_Служебный.ИсключениеНеверныйТип("Файл", "ПолучитьПутьКФайлу", Файл, "Строка, ДвоичныеДанные");
	КонецЕсли;
	
КонецФункции

Функция ПоместитьФайлВоВременнуюПапку(ДвоичныеДанные, Расширение) Экспорт
	
	Попытка
		ПолныйПутьКФайлу = ПутьКНовомуВременномуФайлу(Расширение); 
		ДвоичныеДанные.Записать(ПолныйПутьКФайлу);				
	Исключение
		ОписаниеОшибки = ОписаниеОшибки();
		А1Э_Служебный.СлужебноеИсключение("Не удалось записать файл " + ОписаниеОшибки);      
	КонецПопытки;            
	
	Возврат ПолныйПутьКФайлу;
КонецФункции

Функция ПутьКНовомуВременномуФайлу(Расширение) Экспорт
	ПутьКВременнойПапке = А1Э_Файлы.ЛичнаяВременнаяПапка();
	Если ЗначениеЗаполнено(ПутьКВременнойПапке) Тогда 
		ПолныйПутьКФайлу = ПутьКВременнойПапке + "ВременныйФайл" + Новый УникальныйИдентификатор + "." + Расширение;
		Возврат ПолныйПутьКФайлу;
	Иначе
		А1Э_Служебный.СлужебноеИсключение("Не удалось получить путь ко временной папке!");
	КонецЕсли;
КонецФункции 

Функция ФайлСуществует(ПутьКФайлу) Экспорт
	Файл = Новый Файл(ПутьКФайлу);
	Возврат Файл.Существует();
КонецФункции

Функция СложитьПути(ПерваяЧасть, ВтораяЧасть) Экспорт
	Путь = А1Э_Строки.ЗавершитьПодстрокой(ПерваяЧасть, "\");
	Путь = Путь + ВтораяЧасть;
	Возврат Путь;
КонецФункции

#Если Клиент Тогда
	
	// Открывает диалог выбора файла асинхронно. В веб-клиенте устанавливает и подключает расширение для работы с файлами при необходимости.
	//
	// Параметры:
	//  ИмяПроцедуры - Строка - имя экспортной процедуры, в которую будет передано управление после успешного подключения. 
	//  Модуль		 - ОбщийМодуль, Форма - модуль или форма, в которых расположена процедура
	//  Контекст	 - Произвольный - будет передан во второй параметр вызванной процедуры. Кроме того, ключи Режим, Заголовок, Фильтр, Расширение влияют на поведение диалога выбора файла. 
	// 
	// Возвращаемое значение:
	//   - 
	//
	Функция ПоказатьВыборФайла(ИмяПроцедуры, Модуль, Знач Контекст = Неопределено) Экспорт 
		ВнутреннийКонтекст = А1Э_Структуры.Создать(
		"ВнешнееОповещение", Новый ОписаниеОповещения(ИмяПроцедуры, Модуль, Контекст),
		"Контекст", Контекст,
		);
		А1Э_Файлы.ПодключитьРасширение("__ПоказатьВыборФайла_ПослеПодключенияРасширения", ЭтотОбъект, ВнутреннийКонтекст);
	КонецФункции 
	
	Функция __ПоказатьВыборФайла_ПослеПодключенияРасширения(Результат, ВнутреннийКонтекст) Экспорт
		ДанныеДиалога = А1Э_Общее.ЗначенияСвойств(ВнутреннийКонтекст.Контекст, "Режим,Заголовок,Фильтр,Расширение");
		Если НЕ ЗначениеЗаполнено(ДанныеДиалога.Режим) Тогда
			ДанныеДиалога.Режим = "Открытие";
		КонецЕсли;
		ДанныеДиалога.Режим = А1Э_СтандартныеТипы.РежимДиалогаВыбораФайлаПолучить(ДанныеДиалога.Режим);
		
		Диалог = Новый ДиалогВыбораФайла(ДанныеДиалога.Режим);
		ЗаполнитьЗначенияСвойств(Диалог, ДанныеДиалога, , "Режим");
		Диалог.Показать(ВнутреннийКонтекст.ВнешнееОповещение);
	КонецФункции
	
	// Подключает расширение для работы с файлами. Если подключение не удалось, вызывает исключение.
	// Вне веб-клиента немедленно передает управление в указанную процедуру.
	//
	// Параметры:
	//  ИмяПроцедуры - Строка - имя экспортной процедуры, в которую будет передано управление после успешного подключения. 
	//  Модуль		 - ОбщийМодуль, Форма - модуль или форма, в которых расположена процедура
	//  Контекст	 - Произвольный - будет передан во второй параметр вызванной процедуры. 
	// 
	// Возвращаемое значение:
	//   - 
	//
	Функция ПодключитьРасширение(ИмяПроцедуры, Модуль, Контекст = Неопределено) Экспорт
		Контекст = А1Э_Структуры.Создать(
		"ВнешнееОповещение", Новый ОписаниеОповещения(ИмяПроцедуры, Модуль, Контекст),
		);
		#Если НЕ ВебКлиент Тогда
			ВыполнитьОбработкуОповещения(Контекст.ВнешнееОповещение, Истина);
		#Иначе
			НачатьПодключениеРасширенияРаботыСФайлами(Новый ОписаниеОповещения("__ПодключитьРасширение_ПослеПервогоПодключения", ЭтотОбъект, Контекст));
		#КонецЕсли
	КонецФункции 
	
	Процедура __ПодключитьРасширение_ПослеПервогоПодключения(Результат, Контекст) Экспорт
		Если Результат = Истина Тогда
			ВыполнитьОбработкуОповещения(Контекст.ВнешнееОповещение, Истина);
			Возврат;
		КонецЕсли;
		НачатьУстановкуРасширенияРаботыСФайлами(Новый ОписаниеОповещения("__ПодключитьРасширение_ПослеУстановки", ЭтотОбъект, Контекст));
	КонецПроцедуры
	
	Процедура __ПодключитьРасширение_ПослеУстановки(Контекст) Экспорт 
		НачатьПодключениеРасширенияРаботыСФайлами(Новый ОписаниеОповещения("__ПодключитьРасширение_ПослеВторогоПодключения", ЭтотОбъект, Контекст)); 
	КонецПроцедуры
	
	Процедура __ПодключитьРасширение_ПослеВторогоПодключения(Результат, Контекст) Экспорт
		Если Результат = Истина Тогда
			ВыполнитьОбработкуОповещения(Контекст.ВнешнееОповещение, Истина);
			Возврат;
		КонецЕсли;
		А1Э_Служебный.СлужебноеИсключение("Не удалось подключить расширение по работе с файлами!");
	КонецПроцедуры
	
#КонецЕсли

Функция ИмяМодуля() Экспорт
	Возврат "А1Э_Файлы";
КонецФункции 