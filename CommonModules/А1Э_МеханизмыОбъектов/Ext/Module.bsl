﻿#Область СохранениеИдентификатора

Функция СохранениеИдентификаторов__НастройкиМеханизма() Экспорт
	Настройки = А1Э_Механизмы.НовыйНастройкиМеханизма();
	
	Настройки.Обработчики.Вставить("ПередЗаписью", Истина);

	Настройки.Обработчики.Вставить("А1Э_ПриПоискеОшибок", Истина);
	Настройки.Обработчики.Вставить("А1Э_ПриИсправленииОшибок", Истина);
	
	Настройки.ПорядокВыполнения = -10000;
	
	Возврат Настройки;
КонецФункции 

#Если НЕ Клиент Тогда
	
	Функция СохранениеИдентификаторов__ПередЗаписью(Объект, Отказ, РежимЗаписи = Неопределено, РежимПроведения = Неопределено) Экспорт
		Если НЕ А1Э_Общее.Свойство(Объект, "А1Э_Идентификатор") Тогда Возврат Неопределено; КонецЕсли;
		
		Если ЗначениеЗаполнено(Объект.Ссылка) Тогда
			Ссылка = Объект.Ссылка;	
		Иначе
			Ссылка = А1Э_Метаданные.МенеджерПоСсылке(Объект.Ссылка).ПолучитьСсылку(Новый УникальныйИдентификатор);
			Объект.УстановитьСсылкуНового(Ссылка);
		КонецЕсли;
		Объект.А1Э_Идентификатор = А1Э_Метаданные.ИдентификаторПоСсылке(Ссылка);
	КонецФункции
	
	Функция СохранениеИдентификаторов__А1Э_ПриПоискеОшибок(Ошибки) Экспорт 
		ОбъектыМеханизма = А1Э_Механизмы.ВсеМеханизмыСОбъектами(Ложь)["А1Э_СохранениеИдентификаторов"];
		Если ОбъектыМеханизма = Неопределено Тогда Возврат Неопределено КонецЕсли;
		
		ОбъектыМетаданныхМеханизма = Новый Массив;
		Если ОбъектыМеханизма[А1Э_Механизмы.Адресация__ВсеОбъекты()] <> Неопределено Тогда
			СохранениеИдентификаторов__ДобавитьМетаданные(ОбъектыМетаданныхМеханизма, Метаданные.Справочники);
			СохранениеИдентификаторов__ДобавитьМетаданные(ОбъектыМетаданныхМеханизма, Метаданные.Документы);
			ОбъектыМеханизма.Удалить(А1Э_Механизмы.Адресация__ВсеОбъекты());
		КонецЕсли;
		Для Каждого Пара Из ОбъектыМеханизма Цикл
			ОбъектыМетаданныхМеханизма.Добавить(А1Э_Метаданные.ОбъектМетаданных(Пара.Ключ));
		КонецЦикла;
		А1Э_Массивы.Свернуть(ОбъектыМетаданныхМеханизма);
		
		КорректныеОбъектыМетаданных = Новый Массив;
		Для Каждого ОбъектМетаданных Из ОбъектыМетаданныхМеханизма Цикл
			Если ОбъектМетаданных.Реквизиты.Найти("А1Э_Идентификатор") = Неопределено Тогда
				Ошибки.Добавить(А1Э_Механизмы.НовыйОписаниеОшибки("ОтсутствуетРеквизит", ОбъектМетаданных.ПолноеИмя())); 
				Продолжить;
			КонецЕсли;
			Реквизит = ОбъектМетаданных.Реквизиты.А1Э_Идентификатор;
			Типы = Реквизит.Тип.Типы(); 
			Если Типы.Количество() <> 1 Или Типы[0] <> Тип("Строка") Тогда
				Ошибки.Добавить(А1Э_Механизмы.НовыйОписаниеОшибки("НеверныйТипРеквизита", ОбъектМетаданных.ПолноеИмя()));
				Продолжить;
			КонецЕсли;
			Если Реквизит.Тип.КвалификаторыСтроки.Длина <> 50 Или Реквизит.Тип.КвалификаторыСтроки.ДопустимаяДлина <> ДопустимаяДлина.Переменная Тогда
				Ошибки.Добавить(А1Э_Механизмы.НовыйОписаниеОшибки("НеверныеПараметрыРеквизита", ОбъектМетаданных.ПолноеИмя()));
				Продолжить;
			КонецЕсли;
			Если Реквизит.Индексирование <> Метаданные.СвойстваОбъектов.Индексирование.Индексировать Тогда
				Ошибки.Добавить(А1Э_Механизмы.НовыйОписаниеОшибки("НеверноеИндексированиеРеквизита", ОбъектМетаданных.ПолноеИмя()));
				Продолжить;
			КонецЕсли;
			КорректныеОбъектыМетаданных.Добавить(ОбъектМетаданных);
		КонецЦикла;
		Если КорректныеОбъектыМетаданных.Количество() = 0 Тогда Возврат Неопределено; КонецЕсли;
		
		МассивЗапроса = Новый Массив;
		ШаблонЗапроса = 
		"ВЫБРАТЬ
		|	&ОбъектМетаданных КАК ОбъектМетаданных,
		|	А1Э_ТаблицаОбъекта.Ссылка КАК Ссылка,
		|	А1Э_ТаблицаОбъекта.А1Э_Идентификатор КАК А1Э_Идентификатор
		|ИЗ
		|	&Таблица КАК А1Э_ТаблицаОбъекта";
		Для Каждого ОбъектМетаданных Из КорректныеОбъектыМетаданных Цикл
			ТекстЗапроса = СтрЗаменить(ШаблонЗапроса, "&Таблица", ОбъектМетаданных.ПолноеИмя());
			А1Э_Запросы.ПодставитьСтроку(ТекстЗапроса, "&ОбъектМетаданных", ОбъектМетаданных.ПолноеИмя()); 
			МассивЗапроса.Добавить(ТекстЗапроса);
		КонецЦикла;
		Запрос = Новый Запрос(А1Э_Запросы.Объединить(МассивЗапроса));
		Выборка = Запрос.Выполнить().Выбрать();
		Пока Выборка.Следующий() Цикл
			ПравильныйИдентификатор = А1Э_Метаданные.ИдентификаторПоСсылке(Выборка.Ссылка);
			Если ПравильныйИдентификатор = Выборка.А1Э_Идентификатор Тогда Продолжить; КонецЕсли;
			Ошибки.Добавить(А1Э_Механизмы.НовыйОписаниеОшибки("НеверныйИдентификатор", Выборка.ОбъектМетаданных, Выборка.Ссылка));	
		КонецЦикла;
		
		СписокОшибок = СохранениеИдентификаторов__СписокОшибок();
		Для Каждого Ошибка Из Ошибки Цикл
			ВидОшибкиПоСписку = СписокОшибок[Ошибка.Имя];
			ЗаполнитьЗначенияСвойств(Ошибка, ВидОшибкиПоСписку);
		КонецЦикла;
		
	КонецФункции
	
	Функция СохранениеИдентификаторов__А1Э_ПриИсправленииОшибок(Ошибки) Экспорт
		Для Каждого Ошибка Из Ошибки Цикл
			Если Ошибка.АвтоматическоеИсправление <> Истина Тогда
				Сообщить("Ошибка" + Ошибка.Представление + " не может быть исправлена автоматически!");
			КонецЕсли;
			Если Ошибка.Имя <> "НеверныйИдентификатор" Тогда Продолжить; КонецЕсли;
			
			А1Э_Объекты.ИзменитьСПараметрами(Ошибка.Ссылка, А1Э_Структуры.Создать("ОбменДаннымиЗагрузка", Истина));
		КонецЦикла;
	КонецФункции

	Функция СохранениеИдентификаторов__СписокОшибок() Экспорт
	    СписокОшибок = Новый Соответствие;
		
		СписокОшибок.Вставить("ОтсутствуетРеквизит", А1Э_Структуры.Создать(
		"АвтоматическоеИсправление", Ложь,
		"Представление", "У объекта метаданных отсутствует реквизит <А1Э_Идентификатор>"));
		
		СписокОшибок.Вставить("НеверныйТипРеквизита", А1Э_Структуры.Создать(
		"АвтоматическоеИсправление", Ложь,
		"Представление", "Реквизит <А1Э_Идентификатор> должен быть простого строкового типа"));
		
		СписокОшибок.Вставить("НеверныеПараметрыРеквизита", А1Э_Структуры.Создать(
		"АвтоматическоеИсправление", Ложь,
		"Представление", "Реквизит <А1Э_Идентификатор> должен быть простого строкового типа"));
		
		СписокОшибок.Вставить("НеверноеИндексированиеРеквизита", А1Э_Структуры.Создать(
		"АвтоматическоеИсправление", Ложь,
		"Представление", "Для реквизита <А1Э_Идентификатор> должна быть установлена настройка <Индексировать>"));
		
		СписокОшибок.Вставить("НеверныйИдентификатор", А1Э_Структуры.Создать(
		"АвтоматическоеИсправление", Истина,
		"Представление", "Неверное значение идентификатора"));
		
		Возврат СписокОшибок;
	КонецФункции
	
	Функция СохранениеИдентификаторов__ДобавитьМетаданные(ОбъектыМетаданныхМеханизма, КоллекцияМетаданных)
		Для Каждого ЭлементКоллекции Из КоллекцияМетаданных Цикл
			Если ЭлементКоллекции.Реквизиты.Найти("А1Э_Идентификатор") = Неопределено Тогда Продолжить; КонецЕсли;
			ОбъектыМетаданныхМеханизма.Добавить(ЭлементКоллекции);
		КонецЦикла;
	КонецФункции 
#КонецЕсли

#КонецОбласти

#Область ПроверкаНового

// Механизм позволяет проверить, является ли объект новым, в течение его жизненного цикла после записи в базу данных.
// Для этого в событии "ПередЗаписью" проверяется, является ли объект новым, и результат записывается в ДополнительныеСвойства.А1Э_ЭтоНовый;
Функция ПроверкаНового__НастройкиМеханизма() Экспорт
	Настройки = Новый Структура;
	
	Обработчики = Новый Соответствие;
	Настройки.Вставить("Обработчики", Обработчики);
	Обработчики.Вставить("ПередЗаписью", Истина);
	
	Настройки.Вставить("ПорядокВыполнения", -1000);
	
	Возврат Настройки;
КонецФункции

#Если НЕ Клиент Тогда
	Функция ПроверкаНового__ПередЗаписью(Объект, Отказ, РежимЗаписи = Неопределено, РежимПроведения = Неопределено) Экспорт 
		Объект.ДополнительныеСвойства.Вставить("А1Э_ЭтоНовый", НЕ ЗначениеЗаполнено(Объект.Ссылка));
	КонецФункции
	
	Функция ЭтоНовый(Объект) Экспорт
		Если НЕ Объект.ДополнительныеСвойства.Свойство("А1Э_ЭтоНовый") Тогда
			А1Э_Служебный.СлужебноеИсключение("Не найдено дополнительное свойство объекта А1Э_ЭтоНовый! Подключите механизм А1Э_ПроверкаНового!");
		КонецЕсли;
		Возврат Объект.ДополнительныеСвойства.А1Э_ЭтоНовый;
	КонецФункции 
#КонецЕсли

#КонецОбласти

#Область КонтрольИзменений

// Механизм позволяет получить данные об изменениях объекта. Поддерживает только реквизиты!
// Данные помещаются в "ДополнительныеСвойства.А1Э_Изменения" в виде структуры с ключом - именем реквизита
// и значением - структурой с ключами Исходное, Новое
// Порядок выполнения запредельный, потому что он должен выполняться после всех других обработчиков.
Функция КонтрольИзменений__НастройкиМеханизма() Экспорт
	Настройки = Новый Структура;
	
	Обработчики = Новый Соответствие;
	Настройки.Вставить("Обработчики", Обработчики);
	Обработчики.Вставить("ПередЗаписью", Истина);
	
	Настройки.Вставить("ПорядокВыполнения", 100000);
	
	Возврат Настройки;
КонецФункции 

#Если НЕ Клиент Тогда
	Функция КонтрольИзменений__ПередЗаписью(Объект, Отказ, РежимЗаписи = Неопределено, РежимПроведения = Неопределено) Экспорт
		МетаданныеОбъекта = Объект.Ссылка.Метаданные();
		
		Изменения = Новый Структура;
		Поля = Новый Массив;
		Для Каждого Реквизит Из МетаданныеОбъекта.Реквизиты Цикл
			Поля.Добавить(Реквизит.Имя);
		КонецЦикла;
		Поля.Добавить("ПометкаУдаления");
		ДобавитьСтандартныйРеквизитПриНеобходимости(Поля, Объект, "Номер");
		ДобавитьСтандартныйРеквизитПриНеобходимости(Поля, Объект, "Дата");
		ДобавитьСтандартныйРеквизитПриНеобходимости(Поля, Объект, "Проведен");
		ДобавитьСтандартныйРеквизитПриНеобходимости(Поля, Объект, "Код");
		
		Для Каждого Поле Из Поля Цикл
			Если Объект[Поле] <> Объект.Ссылка[Поле] Тогда
				Изменения.Вставить(Поле, А1Э_Структуры.Создать(
				"Исходное", Объект.Ссылка[Поле],
				"Новое", Объект[Поле]));
			КонецЕсли;
		КонецЦикла;
		
		Объект.ДополнительныеСвойства.Вставить("А1Э_Изменения", Изменения);
	КонецФункции
	
	Функция ДобавитьСтандартныйРеквизитПриНеобходимости(Поля, Объект, Имя)
		Если А1Э_Общее.Свойство(Объект, Имя) Тогда
			Поля.Добавить(Имя);
		КонецЕсли;
	КонецФункции 
#КонецЕсли

#КонецОбласти

#Область ПроверкаУникальностиРеквизитов

//Механизм позволяет при записи проверять, является ли значение реквизита уникальным среди всех элементов справочника/документа.
//При подключении в качестве контекста указываются имена проверяемых реквизитов в виде строки через запятую или в виде массива.
Функция ПроверкаУникальностиРеквизитов__НастройкиМеханизма() Экспорт
	Настройки = А1Э_Механизмы.НовыйНастройкиМеханизма();
	
	Настройки.Обработчики.Вставить("ПередЗаписью", Истина);
	Настройки.Обработчики.Вставить("А1Э_ПриПодключенииКонтекста", Истина);
	Настройки.ПорядокВыполнения = 1000000;
	
	Возврат Настройки;
КонецФункции 

#Если НЕ Клиент Тогда
	
	Функция ПроверкаУникальностиРеквизитов__ПередЗаписью(Объект, Отказ, РежимЗаписи = Неопределено, РежимПроведения = Неопределено) Экспорт
		Если Объект.ПометкаУдаления = Истина Тогда Возврат Неопределено; КонецЕсли;
		//ТУДУ: Сделать одним запросом.
		УстановитьПривилегированныйРежим(Истина);
		Контекст = А1Э_Механизмы.КонтекстМеханизма(Объект, "А1Э_ПроверкаУникальностиРеквизитов");
		Для Каждого ИмяРеквизита Из Контекст Цикл
			Если НЕ ЗначениеЗаполнено(Объект[ИмяРеквизита]) Тогда Продолжить; КонецЕсли;
			Если Объект[ИмяРеквизита] = Объект.Ссылка[ИмяРеквизита] Тогда Продолжить; КонецЕсли;
			
			Запрос = Новый Запрос( 
			"ВЫБРАТЬ
			|	Таблица.Ссылка КАК Ссылка
			|ИЗ
			|	&ИмяТаблицы КАК Таблица
			|ГДЕ
			|	Таблица.ИмяРеквизита = &ЗначениеРеквизита
			|	И Таблица.Ссылка <> &Ссылка
			|	И Таблица.ПометкаУдаления = ЛОЖЬ");
			А1Э_Строки.Подставить(Запрос.Текст, "&ИмяТаблицы", Объект.Метаданные().ПолноеИмя());
			А1Э_Строки.Подставить(Запрос.Текст, "ИмяРеквизита", ИмяРеквизита);
			Запрос.УстановитьПараметр("ЗначениеРеквизита", Объект[ИмяРеквизита]);
			Запрос.УстановитьПараметр("Ссылка", Объект.Ссылка);
			Результат = Запрос.Выполнить();
			Если Результат.Пустой() Тогда Продолжить; КонецЕсли;
			
			Отказ = Истина;
			Выборка = Результат.Выбрать();
			Пока Выборка.Следующий() Цикл
				ТекстСообщения = "Запись невозможна: обнаружено совпадение значения уникального реквизита " + ИмяРеквизита + "!" + Символы.ПС
				+ "Проверьте объект " + Выборка.Ссылка;
				А1Э_Сообщения.СообщитьСДанными(ТекстСообщения, Выборка.Ссылка);
			КонецЦикла;
			Возврат Неопределено;
		КонецЦикла;
		УстановитьПривилегированныйРежим(Ложь);
	КонецФункции 
	
	Функция ПроверкаУникальностиРеквизитов__А1Э_ПриПодключенииКонтекста(ТекущийКонтекст, НовыйКонтекст) Экспорт 
		Если ТекущийКонтекст = Неопределено Тогда ТекущийКонтекст = Новый Массив; КонецЕсли;
		
		НовыйКонтекст = А1Э_Массивы.Массив(НовыйКонтекст);
		Для Каждого Элемент Из НовыйКонтекст Цикл
			Если ТипЗнч(Элемент) <> Тип("Строка") Тогда
				А1Э_Служебный.СлужебноеИсключение("Ошибка подключения механизма <ПроверкаУникальностиРеквизитов>: элемент контекста должен быть строкой");
			КонецЕсли;
			ТекущийКонтекст.Добавить(Элемент);
		КонецЦикла;
	КонецФункции

#КонецЕсли


#КонецОбласти

#Область СписокИзменений

// Формирует список изменений документа и добавляет его в ДополнительныеСвойства.А1Э_СписокИзменений. 
// Выполняется в обработчике "ПередЗаписью", после всех остальных механизмов (очень большой порядок выполнения).
// После себя вызывает событие "А1Э_ПередЗаписьюБезИзменений"
// В данный момент поддерживает только реквизиты, без Табличных частей.
//
//  Возвращаемое значение:
//   - 
//
Функция СписокИзменений__НастройкиМеханизма() Экспорт
	Настройки = А1Э_Механизмы.НовыйНастройкиМеханизма();
	
	Настройки.Обработчики.Вставить("ПередЗаписью", Истина);
	
	Настройки.ПорядокВыполнения = 10000000;
	
	Возврат Настройки; 
КонецФункции 

Функция СписокИзменений__ПередЗаписью(Объект, Отказ, РежимЗаписи = Неопределено, РежимПроведения = Неопределено) Экспорт
	Объект.ДополнительныеСвойства.Вставить("А1Э_СписокИзменений", СписокИзменений(Объект, РежимЗаписи));
КонецФункции

Функция СписокИзменений(Объект, РежимЗаписи = Неопределено) Экспорт
	Изменения = Новый Структура;
	Поля = А1Э_Объекты.МассивПолей(Объект);
	Для Каждого Поле Из Поля Цикл
		Если Объект[Поле] = Объект.Ссылка[Поле] Тогда Продолжить; КонецЕсли;
		Изменения.Вставить(Поле, А1Э_Структуры.Создать(
		"СтароеЗначение", Объект.Ссылка[Поле],
		"НовоеЗначение", Объект[Поле],
		));
	КонецЦикла;
	Если РежимЗаписи = РежимЗаписиДокумента.Проведение И Объект.Ссылка.Проведен = Ложь Тогда
		Изменения.Вставить("Проведен", А1Э_Структуры.Создать(
		"СтароеЗначение", Ложь,
		"НовоеЗначение", Истина,
		));
	ИначеЕсли РежимЗаписи = РежимЗаписиДокумента.ОтменаПроведения И Объект.Ссылка.Проведен = Истина Тогда
		Изменения.Вставить("Проведен", А1Э_Структуры.Создать(
		"СтароеЗначение", Истина,
		"НовоеЗначение", Ложь,
		));
	КонецЕсли;
	Для Каждого ТЧ из Объект.Метаданные().ТабличныеЧасти Цикл
		ИзмененияТЧ = СписокИзмененийТЧ(Объект, ТЧ.Имя);
		Если ИзмененияТЧ.Количество() > 0 Тогда
			Изменения.Вставить(ТЧ.Имя, ИзмененияТЧ);
		КонецЕсли;
	КонецЦикла;
	Возврат Изменения;	
КонецФункции

Функция СписокИзмененийТЧ(Объект, ИмяТЧ) Экспорт
	Результат = Новый Соответствие;
	
	Поля = А1Э_Объекты.МассивПолейТЧ(Объект, ИмяТЧ);
	ТЧОбъекта = Объект[ИмяТЧ]; 
	ТЧСсылки = Объект.Ссылка[ИмяТЧ];
	КоличествоСтрокТЧОбъекта = ТЧОбъекта.Количество();
	КоличествоСтрокТЧСсылки = ТЧСсылки.Количество();
	Если КоличествоСтрокТЧОбъекта >= КоличествоСтрокТЧСсылки Тогда
		ИтерируемаяКоллекция = ТЧОбъекта;
		КлючИтерируемойКоллекции = "НовоеЗначение";
		СравниваемаяКоллекция = ТЧСсылки;
		КлючСравниваемойКоллекции = "СтароеЗначение";
		Ограничение = КоличествоСтрокТЧСсылки;
	Иначе
		ИтерируемаяКоллекция = ТЧСсылки;
		КлючИтерируемойКоллекции = "СтароеЗначение";
		СравниваемаяКоллекция = ТЧОбъекта;
		КлючСравниваемойКоллекции = "НовоеЗначение";
		Ограничение = КоличествоСтрокТЧОбъекта;
	КонецЕсли;
	Для Каждого ИтерируемаяСтрока ИЗ ИтерируемаяКоллекция Цикл
		Если ИтерируемаяСтрока.НомерСтроки > Ограничение Тогда
			СравниваемаяСтрока = Null;
		Иначе
			СравниваемаяСтрока = СравниваемаяКоллекция[ИтерируемаяСтрока.НомерСтроки - 1];
		КонецЕсли;
		Для Каждого Поле Из Поля Цикл
			Если СравниваемаяСтрока = Null Или ИтерируемаяСтрока[Поле] <> СравниваемаяСтрока[Поле] Тогда 
				
				Если Результат[ИтерируемаяСтрока.НомерСтроки] = Неопределено Тогда
					Результат.Вставить(ИтерируемаяСтрока.НомерСтроки, Новый Структура);
				КонецЕсли;  
				
				Результат[ИтерируемаяСтрока.НомерСтроки].Вставить(Поле, А1Э_Структуры.Создать(
				КлючСравниваемойКоллекции, ?(СравниваемаяСтрока = Null, Null, СравниваемаяСтрока[Поле]),
				КлючИтерируемойКоллекции, ИтерируемаяСтрока[Поле],
				));
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;		
	Возврат Результат;
КонецФункции

#КонецОбласти

#Область ЗаполнениеПоУмолчанию

// Заполняет объект отборами списка
// 
// Возвращаемое значение:
//   - 
//
Функция ЗаполнениеПоУмолчанию__НастройкиМеханизма() Экспорт
	Настройки = А1Э_Механизмы.НовыйНастройкиМеханизма();
	
	Настройки.Обработчики.Вставить("ОбработкаЗаполнения", Истина);
	
	Настройки.ПорядокВыполнения = -1000;
	
	Возврат Настройки;
КонецФункции

Функция ЗаполнениеПоУмолчанию__ОбработкаЗаполнения(Объект, ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка) Экспорт
	Если ТипЗнч(ДанныеЗаполнения) = Тип("Структура") Тогда
		ЗаполнитьЗначенияСвойств(Объект, ДанныеЗаполнения);
	КонецЕсли;
КонецФункции 
	
#КонецОбласти 

