﻿Функция ЖСОН(Данные, ЗаписьЖСОН = Неопределено) Экспорт
	
	Если ЗаписьЖСОН = Неопределено Тогда
		ЗаписьЖСОН = Новый ЗаписьJSON;
		ЗаписьЖСОН.УстановитьСтроку();
		ВозвращатьСтроку = Истина;
	Иначе
		ВозвращатьСтроку = Ложь;
	КонецЕсли;
	
	Попытка
		ЗаписатьJSON(ЗаписьЖСОН, Данные);
		Если ВозвращатьСтроку Тогда
			Возврат ЗаписьЖСОН.Закрыть();
		КонецЕсли;
	Исключение
		ОписаниеОшибки = ОписаниеОшибки();
		ВызватьИсключение "Ошибка сериализации JSON: " + ОписаниеОшибки;
	КонецПопытки;
КонецФункции

Функция ЗначениеЖСОН(Знач Строка) Экспорт
	Строка = СтрЗаменить(Строка, "\u0000", ""); //Убираем Null-символы - не читаются корректно парсером. ТУДУ: А если это реальная строка?
	ЧтениеЖСОН = Новый ЧтениеJSON;
	ЧтениеЖСОН.УстановитьСтроку(Строка);
	Возврат ПрочитатьJSON(ЧтениеЖСОН);
КонецФункции

#Область УниверсальныйЖСОН
#Если НЕ Клиент Тогда
	
	Функция РазвернутьУниверсальныйЖСОН(Строка) Экспорт
		Попытка
			БазовоеЗначение = ЗначениеЖСОН(Строка);
		Исключение
			ОписаниеОшибки = ОписаниеОшибки();
			А1Э_Служебный.СлужебноеИсключение("Невозможно прочитать универсальный JSON по причине:" + Символы.ПС +
			"Ошибка стандартного чтения. Возможно неверно закодированы ссылки из другой информационной базы!");
		КонецПопытки;
		
		Возврат РазвернутьБазовоеЗначениеРекурсивно(БазовоеЗначение);
	КонецФункции
	
	#Область РазвернутьУниверсальныйЖСОН
	
	Функция РазвернутьБазовоеЗначениеРекурсивно(БазовоеЗначение)   
		Если ТипЗнч(БазовоеЗначение) = Тип("Строка") Тогда
			Возврат РазвернутьСтроку(БазовоеЗначение);
		ИначеЕсли А1Э_СтандартныеТипы.Примитивный(БазовоеЗначение) Тогда
			Возврат БазовоеЗначение;
		ИначеЕсли ТипЗнч(БазовоеЗначение) = Тип("ДвоичныеДанные") Тогда
			Возврат БазовоеЗначение;
		ИначеЕсли ТипЗнч(БазовоеЗначение) = Тип("Структура") Или ТипЗнч(БазовоеЗначение) = Тип("ФиксированнаяСтруктура") Тогда
			Возврат РазвернутьСтруктуру(БазовоеЗначение);
		ИначеЕсли ТипЗнч(БазовоеЗначение) = Тип("Массив") Или ТипЗнч(БазовоеЗначение) = Тип("ФиксированныйМассив") Тогда			
			РезультатРазвертки = Новый Массив;
			Для Каждого Элемент Из БазовоеЗначение Цикл
				РезультатРазвертки.Добавить(РазвернутьБазовоеЗначениеРекурсивно(Элемент));
			КонецЦикла;
		ИначеЕсли ТипЗнч(БазовоеЗначение) = Тип("Соответствие") Или ТипЗнч(БазовоеЗначение) = Тип("ФиксированноеСоответствие") Тогда
			РезультатРазвертки = Новый Соответствие;
			Для Каждого Пара Из БазовоеЗначение Цикл
				РезультатРазвертки.Вставить(Пара.Ключ, РазвернутьБазовоеЗначениеРекурсивно(Пара.Значение));
			КонецЦикла;
		Иначе
			А1Э_Служебный.СлужебноеИсключение("Значение типа " + ТипЗнч(БазовоеЗначение) + " не поддерживается!");
		КонецЕсли;
		
		Возврат РезультатРазвертки;		
	КонецФункции 
	
	Функция РазвернутьСтруктуру(Структура)
		Класс = А1Э_Классы.Класс(Структура); 
		Если Класс = "А1УЖ_Ссылка" Тогда 
			Возврат РазвернутьСсылку(Структура);			
		ИначеЕсли Класс = "А1УЖ_ТабличныйДокумент" Тогда
			Возврат РазвернутьТабличныйДокумент(Структура);
		ИначеЕсли Класс = "А1УЖ_Нулл" Тогда
			Возврат Null;
		Иначе
			РезультатРазвертки = Новый Структура;
			Для Каждого Пара Из Структура Цикл
				РезультатРазвертки.Вставить(Пара.Ключ, РазвернутьБазовоеЗначениеРекурсивно(Пара.Значение));
			КонецЦикла;
		КонецЕсли;
		Возврат РезультатРазвертки;
	КонецФункции 
	
	Функция РазвернутьСсылку(СтруктураСсылки)
		Тип = СтруктураСсылки.Тип;
		Точка = СтрНайти(Тип, ".");
		Если Точка > 0 Тогда
			ТипОбъекта = Лев(Тип, Точка - 1);
			ИмяОбъекта = Сред(Тип, Точка + 1);
		Иначе
			ТипОбъекта = Неопределено;
			ИмяОбъекта = Тип;
		КонецЕсли;
		МенеджерОбъекта = А1Э_Метаданные.МенеджерОбъекта(ИмяОбъекта, ТипОбъекта);
		
		Если СтруктураСсылки.Ключ = "_UID" ИЛИ СтруктураСсылки.Ключ = "_УИД" Тогда
			Возврат МенеджерОбъекта.ПолучитьСсылку(Новый УникальныйИдентификатор(СтруктураСсылки.Знач));
		Иначе
			Возврат МенеджерОбъекта.НайтиПоРеквизиту(СтруктураСсылки.Ключ, СтруктураСсылки.Знач);
		КонецЕсли;
		
	КонецФункции 
	
	Функция РазвернутьТабличныйДокумент(СтруктураТабличногоДокумента) 
		ДвоичныеДанные = Base64Значение(СтруктураТабличногоДокумента.Данные);
		Поток = ДвоичныеДанные.ОткрытьПотокДляЧтения();
		ТабличныйДокумент = Новый ТабличныйДокумент;
		ТабличныйДокумент.Прочитать(Поток);
		Возврат ТабличныйДокумент;
	КонецФункции
	
	// Возвращает дату, если строка представляет собой дату по ISO 8601. Иначе возвращает исходную строку
	//
	// Параметры:
	//  Строка	 - 	 - 
	// 
	// Возвращаемое значение:
	//   - 
	//
	Функция РазвернутьСтроку(Строка)
		Если НЕ (Сред(Строка, 5, 1) = "-" И Сред(Строка, 8, 1) = "-" И Сред(Строка, 11, 1) = "T" И
			Сред(Строка, 14, 1) = ":" И Сред(Строка, 17, 1) = ":") Тогда Возврат Строка КонецЕсли;
		Попытка
			Возврат А1Э_Даты.ИзЖСОН(Строка); 
		Исключение
			Возврат Строка;
		КонецПопытки;
	КонецФункции
	
	#КонецОбласти 
	
	Функция СвернутьУниверсальныйЖСОН(Значение) Экспорт
		УниверсальноеЗначение = СвернутьБазовоеЗначениеРекурсивно(Значение);
		Возврат ЖСОН(УниверсальноеЗначение); 
	КонецФункции
	
	#Область СвернутьУниверсальныйЖСОН
	
	Функция СвернутьБазовоеЗначениеРекурсивно(БазовоеЗначение)
		Если БазовоеЗначение = Null Тогда
			Возврат СвернутьНулл();
		ИначеЕсли А1Э_СтандартныеТипы.Примитивный(БазовоеЗначение) Тогда
			Возврат БазовоеЗначение;
		ИначеЕсли А1Э_СтандартныеТипы.ЭтоСсылка(БазовоеЗначение) Тогда
			Возврат СвернутьСсылку(БазовоеЗначение, "_UID");
		ИначеЕсли ТипЗнч(БазовоеЗначение) = Тип("ДвоичныеДанные") Тогда
			Возврат БазовоеЗначение;
		ИначеЕсли ТипЗнч(БазовоеЗначение) = Тип("Структура") Или ТипЗнч(БазовоеЗначение) = Тип("ФиксированнаяСтруктура") Тогда
			РезультатСвертки = Новый Структура;
			Для Каждого Пара Из БазовоеЗначение Цикл
				РезультатСвертки.Вставить(Пара.Ключ, СвернутьБазовоеЗначениеРекурсивно(Пара.Значение));
			КонецЦикла;
		ИначеЕсли ТипЗнч(БазовоеЗначение) = Тип("Массив") Или ТипЗнч(БазовоеЗначение) = Тип("ФиксированныйМассив") Тогда			
			РезультатСвертки = Новый Массив;
			Для Каждого Элемент Из БазовоеЗначение Цикл
				РезультатСвертки.Добавить(СвернутьБазовоеЗначениеРекурсивно(Элемент));
			КонецЦикла;
		ИначеЕсли ТипЗнч(БазовоеЗначение) = Тип("Соответствие") Или ТипЗнч(БазовоеЗначение) = Тип("ФиксированноеСоответствие") Тогда
			РезультатСвертки = Новый Соответствие;
			Для Каждого Пара Из БазовоеЗначение Цикл
				РезультатСвертки.Вставить(Пара.Ключ, СвернутьБазовоеЗначениеРекурсивно(Пара.Значение));
			КонецЦикла;
		ИначеЕсли ТипЗнч(БазовоеЗначение) = Тип("ТабличныйДокумент") Тогда
			Возврат СвернутьТабличныйДокумент(БазовоеЗначение); 
		Иначе
			А1Э_Служебный.СлужебноеИсключение("Значение типа " + ТипЗнч(БазовоеЗначение) + " не поддерживается!");
		КонецЕсли;
		
		Возврат РезультатСвертки;	
	КонецФункции 
	
	Функция СвернутьСсылку(Ссылка, Ключ)
		СтруктураСсылки = Новый Структура("Класс", "А1УЖ_Ссылка");
		СтруктураСсылки.Вставить("Тип", Ссылка.Метаданные().ПолноеИмя());
		СтруктураСсылки.Вставить("Ключ", Ключ);
		Если Ключ = "_УИД" Или Ключ = "_UID" Тогда
			СтруктураСсылки.Вставить("Знач", Строка(Ссылка.УникальныйИдентификатор()));
		Иначе
			СтруктураСсылки.Вставить("Знач", Ссылка[Ключ]);
		КонецЕсли;
		Возврат СтруктураСсылки;
	КонецФункции
	
	Функция СвернутьТабличныйДокумент(ТабличныйДокумент)
		РезультатСвертки = Новый Структура("Класс", "А1УЖ_ТабличныйДокумент");
		ПотокФайла = Новый ПотокВПамяти();
		ТабличныйДокумент.Записать(ПотокФайла);
		ДвоичныеДанные = ПотокФайла.ЗакрытьИПолучитьДвоичныеДанные();
		РезультатСвертки.Вставить("Данные", Base64Строка(ДвоичныеДанные));
		Возврат РезультатСвертки;
	КонецФункции
	
	Функция СвернутьНулл()
		Возврат Новый Структура("Класс", "А1УЖ_Нулл");
	КонецФункции
	
	#КонецОбласти 
	
#КонецЕсли
#КонецОбласти 

#Область XDTO

Функция ЖСОН_ХДТО(Данные, ЗаписьЖСОН = Неопределено) Экспорт
	Если ЗаписьЖСОН = Неопределено Тогда
		ЗаписьЖСОН = Новый ЗаписьJSON;
		ЗаписьЖСОН.УстановитьСтроку();
		ВозвращатьСтроку = Истина;
	Иначе
		ВозвращатьСтроку = Ложь;
	КонецЕсли;
	
	Попытка
		// Создать сериализатор XDTO для глобальной фабрики XDTO
		НовыйСериализаторXDTO = Новый СериализаторXDTO(ФабрикаXDTO);
		НовыйСериализаторXDTO.ЗаписатьJSON(ЗаписьЖСОН, Данные, НазначениеТипаXML.Явное);
		
		Если ВозвращатьСтроку Тогда
			Возврат ЗаписьЖСОН.Закрыть();
		КонецЕсли;
	Исключение
		ОписаниеОшибки = ОписаниеОшибки();
		ВызватьИсключение "Ошибка сериализации в JSON через XDTO: " + ОписаниеОшибки; 	
	КонецПопытки
КонецФункции 

#КонецОбласти 

#Область DOM

#Область XML

Функция ДОМ_ИзСтрокиХМЛ(Строка) Экспорт
	ЧтениеХМЛ = Новый ЧтениеXML;
	ЧтениеХМЛ.УстановитьСтроку(Строка);
	Построитель = Новый ПостроительDOM;
	ДокументДОМ = Построитель.Прочитать(ЧтениеХМЛ);
	Возврат ДокументДОМ;
КонецФункции

Функция ДОМ_ИзФайлаХМЛ(ПолноеИмяФайла, Кодировка = Неопределено) Экспорт
	Возврат ДОМ_ИзСтрокиХМЛ(А1Э_Строки.ИзФайлаСинхронно(ПолноеИмяФайла, Кодировка));
КонецФункции 

Функция ДОМ_ИзМакетаХМЛ(ПолноеИмяМакета) Экспорт
	Возврат ДОМ_ИзСтрокиХМЛ(А1Э_Строки.ИзМакета(ПолноеИмяМакета));	
КонецФункции

Функция ДОМ_ВСтрокуХМЛ(ДокументДОМ) Экспорт
	ЗаписьХМЛ = Новый ЗаписьXML;
	ЗаписьХМЛ.УстановитьСтроку(ДокументДОМ.КодировкаИсточника);
	ЗаписьДОМ = Новый ЗаписьDOM;
	ЗаписьДОМ.Записать(ДокументДОМ, ЗаписьХМЛ);
	Строка = ЗаписьХМЛ.Закрыть();
	Возврат Строка;
КонецФункции

Функция ДОМ_ВФайлХМЛ(ДокументДОМ, ПолноеИмяФайла) Экспорт
	А1Э_Строки.ВФайлСинхронно(ДОМ_ВСтрокуХМЛ(ДокументДОМ), ПолноеИмяФайла, ДокументДОМ.КодировкаИсточника);
КонецФункции

#КонецОбласти 

#Область Трансформации

Функция ДОМ_ДобавитьЭлемент(ДокументДОМ, Имя, Родитель = Неопределено) Экспорт
	Элемент = ДокументДОМ.СоздатьЭлемент(Имя);
	Если Родитель <> Неопределено Тогда
		Родитель.ДобавитьДочерний(Элемент);
	КонецЕсли;
	Возврат Элемент;
КонецФункции

#КонецОбласти 

#КонецОбласти 