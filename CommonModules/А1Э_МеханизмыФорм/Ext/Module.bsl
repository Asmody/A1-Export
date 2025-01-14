﻿#Область ВводНаОсновании

Функция ВводНаОсновании__НастройкиМеханизма() Экспорт
	Настройки = А1Э_Механизмы.НовыйНастройкиМеханизма();
	
	Настройки.Обработчики.Вставить("А1Э_ПриПодключенииКонтекста", Истина);
	Настройки.Обработчики.Вставить("ФормаПриСозданииНаСервере", Истина);
	
	Возврат Настройки;
КонецФункции

Функция ВводНаОсновании__ЭлементКонтекста(Объект, Имя, Заголовок, Действие) Экспорт
	Возврат А1Э_Структуры.Создать(
	"Объект", Объект,
	"Имя", Имя,
	"Заголовок", Заголовок,
	"Действие", Действие,
	);
КонецФункции

// Эта функция прерывает ввод на основании путем вызова исключения со специальной строкой.
// Предполагается, что обработчик ввода на основании может поймать эту ошибку и показать пользователю корректную информацию.
//
// Параметры:
//  Объект	 - Объект - 
//  Причина	 - 	 - 
// 
// Возвращаемое значение:
//   - 
//
Функция ВводНаОсновании__ПрерываниеВвода(Объект, Причина) Экспорт
	ВызватьИсключение "[ВводНаОсновании__ПрерываниеВвода:" + Причина + "]"; 
КонецФункции

#Если НЕ Клиент Тогда
	
	Функция ВводНаОсновании__А1Э_ПриПодключенииКонтекста(ТекущийКонтекст, НовыйКонтекст) Экспорт
		Если ТекущийКонтекст = Неопределено Тогда
			ТекущийКонтекст = Новый Массив;
		КонецЕсли;
		
		НовыйКонтекстМассив = А1Э_Массивы.Массив(НовыйКонтекст);
		
		Для Каждого ЭлементКонтекста Из НовыйКонтекстМассив Цикл
			ОписаниеКоманды = НовыйОписаниеКомандыМетаданных(ЭлементКонтекста, "А1Э_ВводНаОсновании", ИмяМодуля() + ".ВводНаОсновании__ДействиеПоУмолчанию");
			Если НЕ ЗначениеЗаполнено(ОписаниеКоманды.Заголовок) Тогда
				ОписаниеКоманды.Заголовок = А1Э_Метаданные.ПредставлениеОдного(ОписаниеКоманды.Объект);			
			КонецЕсли;
			ТекущийКонтекст.Добавить(ОписаниеКоманды);
		КонецЦикла;
	КонецФункции
	
	Функция ВводНаОсновании__ФормаПриСозданииНаСервере(Форма, Отказ, СтандартнаяОбработка) Экспорт
		ТипФормы = А1Э_Формы.ТипФормы(Форма);
		Если ТипФормы <> "ФормаЭлемента" И ТипФормы <> "ФормаСписка" Тогда Возврат Неопределено; КонецЕсли;
		Контекст = А1Э_Механизмы.КонтекстМеханизма(Форма, "А1Э_ВводНаОсновании");
		Если ТипЗнч(Контекст) <> Тип("Массив") Тогда
			Сообщить("Неверный контекст механизма А1Э_ВводНаОсновании. Ожидается массив!");
			Возврат Неопределено;
		КонецЕсли;
		
		МассивОписаний = Новый Массив;
		//Ищем стандартную группу, если она есть и не пустая - используем её. Если пустая, то она потом не отображается на форме.
		Если Форма.Элементы.Найти("ФормаСоздатьНаОсновании") <> Неопределено И Форма.Элементы.ФормаСоздатьНаОсновании.ПодчиненныеЭлементы.Количество() > 0 Тогда 
			РодительЭлементов = "ФормаСоздатьНаОсновании";
		Иначе
			А1Э_Формы.ДобавитьОписаниеГруппы(МассивОписаний, "А1Э_ВводНаОсновании__ГруппаКоманд", "Создать на основании", А1Э_Формы.КоманднаяПанель(Форма), ,
			А1Э_Структуры.Создать(
			"Вид", ВидГруппыФормы.Подменю));
			РодительЭлементов = "А1Э_ВводНаОсновании__ГруппаКоманд";
		КонецЕсли;
		
		Для Каждого Команда Из Контекст Цикл
			Если НЕ А1Э_Доступы.ЕстьПраво("Добавление", Команда.Объект) Тогда Продолжить; КонецЕсли;
			ИмяКомпонента = "А1Э_ВводНаОсновании__" + Команда.Имя;
			А1Э_УниверсальнаяФорма.ДобавитьОписаниеНастроекКомпонента(МассивОписаний, ИмяКомпонента, А1Э_Структуры.Создать(
			"Действие", Команда.Действие,
			"Объект", Команда.Объект,
			));   
			А1Э_Формы.ДобавитьОписаниеКомандыИКнопки(МассивОписаний, ИмяКомпонента, "А1Э_МеханизмыФорм.ВводНаОсновании__ОбработчикКоманды", , Команда.Заголовок, РодительЭлементов);
		КонецЦикла;
		А1Э_УниверсальнаяФорма.ДобавитьРеквизитыИЭлементы(Форма, МассивОписаний);
	КонецФункции
	
#КонецЕсли
#Если Клиент Тогда
	
	Функция ВводНаОсновании__ОбработчикКоманды(Форма, Команда) Экспорт
		ТипФормы = А1Э_Формы.ТипФормы(Форма);
				
		Ссылка = ТекущаяСсылка(Форма);
		Если Ссылка = Неопределено Тогда Возврат Неопределено; КонецЕсли;
		
		ПараметрыКоманды = А1Э_УниверсальнаяФорма.НастройкиКомпонента(Форма, Команда.Имя); 
		Контекст = А1Э_Структуры.Создать(
		"Ссылка", Ссылка,
		"Объект", ПараметрыКоманды.Объект,
		"Действие", ПараметрыКоманды.Действие,
		"Модуль", ЭтотОбъект,
		);
		Если ТипФормы = "ФормаЭлемента" Тогда
			А1Э_Формы.ЗаписатьСПредупреждениемПриНеобходимости(Форма, "ВводНаОсновании__ОбработчикКомандыЗавершение", Контекст);
		Иначе
			ВводНаОсновании__ОбработчикКомандыЗавершение(Истина, Контекст);
		КонецЕсли;
	КонецФункции
	
	Функция ВводНаОсновании__ОбработчикКомандыЗавершение(Результат, Контекст) Экспорт
		Попытка
			А1Э_Общее.РезультатФункции(Контекст.Действие, Контекст.Ссылка, Контекст.Объект);
		Исключение
			//Обработка прерывания ввода
			ОписаниеОшибки = ОписаниеОшибки();
			Если СтрНайти(ОписаниеОшибки, "[ВводНаОсновании__ПрерываниеВвода:") <> 0 Тогда
				СтрокаИсключения = А1Э_Строки.Между(ОписаниеОшибки, "[ВводНаОсновании__ПрерываниеВвода:", "]");
			Иначе
				СтрокаИсключения = ОписаниеОшибки; 
			КонецЕсли;
			ВызватьИсключение СтрокаИсключения;
		КонецПопытки;
	КонецФункции
	
	Функция ВводНаОсновании__ДействиеПоУмолчанию(Ссылка, Объект) Экспорт
		ПараметрыФормы = А1Э_Структуры.Создать(
		"Основание", Ссылка); 
		ОткрытьФорму(Объект + ".ФормаОбъекта", ПараметрыФормы);
	КонецФункции 
	
#КонецЕсли
#КонецОбласти

#Область Переходы

Функция Переходы__НастройкиМеханизма() Экспорт
	Настройки = А1Э_Механизмы.НовыйНастройкиМеханизма();
	
	Настройки.Обработчики.Вставить("А1Э_ПриПодключенииКонтекста", Истина);
	Настройки.Обработчики.Вставить("ФормаПриСозданииНаСервере", Истина);
	
	Возврат Настройки;
КонецФункции

#Если НЕ Клиент Тогда
	
Функция Переходы__А1Э_ПриПодключенииКонтекста(ТекущийКонтекст, НовыйКонтекст) Экспорт 
	Если ТекущийКонтекст = Неопределено Тогда
		ТекущийКонтекст = Новый Массив;
	КонецЕсли;
	
	НовыйКонтекстМассив = А1Э_Массивы.Массив(НовыйКонтекст);
	
	Для Каждого ЭлементКонтекста Из НовыйКонтекстМассив Цикл
		Если ТипЗнч(ЭлементКонтекста) = Тип("Строка") Тогда
			Части = А1Э_Строки.ПередПосле(ЭлементКонтекста, ":");
			РабочийЭлемент = Новый Структура("Объект", Части.Перед);
			ПолеОтбора = Части.После;
		Иначе
			РабочийЭлемент = ЭлементКонтекста;
			ПолеОтбора = ЭлементКонтекста.ПолеОтбора;
		КонецЕсли;
		ОписаниеКоманды = НовыйОписаниеКомандыМетаданных(РабочийЭлемент, "А1Э_Переходы", ИмяМодуля() + ".Переходы__ДействиеПоУмолчанию");
		Если НЕ ЗначениеЗаполнено(ОписаниеКоманды.Заголовок) Тогда
			ОписаниеКоманды.Заголовок = А1Э_Метаданные.ПредставлениеНескольких(ОписаниеКоманды.Объект);
		КонецЕсли;	
		ОписаниеКоманды.Вставить("ПолеОтбора", ПолеОтбора);
		ТекущийКонтекст.Добавить(ОписаниеКоманды);
	КонецЦикла;
	
КонецФункции

Функция Переходы__ФормаПриСозданииНаСервере(Форма, Отказ, СтандартнаяОбработка) Экспорт
	ТипФормы = А1Э_Формы.ТипФормы(Форма);
	Если ТипФормы <> "ФормаЭлемента" И ТипФормы <> "ФормаСписка" Тогда Возврат Неопределено; КонецЕсли;
	
	Контекст = А1Э_Механизмы.КонтекстМеханизма(Форма, "А1Э_Переходы");
	Если ТипЗнч(Контекст) <> Тип("Массив") Тогда
		Сообщить("Неверный контекст механизма А1Э_ВводНаОсновании. Ожидается массив!");
		Возврат Неопределено;
	КонецЕсли;
	
	МассивОписаний = Новый Массив;
	А1Э_Формы.ДобавитьОписаниеГруппы(МассивОписаний, "А1Э_Переходы__ГруппаКоманд", "Перейти", Форма.КоманднаяПанель, ,
	А1Э_Структуры.Создать(
	"Вид", ВидГруппыФормы.Подменю));
	
	Для Каждого Команда Из Контекст Цикл
		ИмяКомпонента = "А1Э_Переходы__" + Команда.Имя;
		А1Э_УниверсальнаяФорма.ДобавитьОписаниеНастроекКомпонента(МассивОписаний, ИмяКомпонента, А1Э_Структуры.Создать(
		"Действие", Команда.Действие,
		"Объект", Команда.Объект,
		"ПолеОтбора", Команда.ПолеОтбора,
		));   
		А1Э_Формы.ДобавитьОписаниеКомандыИКнопки(МассивОписаний, ИмяКомпонента, "А1Э_МеханизмыФорм.Переходы__ОбработчикКоманды", , Команда.Заголовок, "А1Э_Переходы__ГруппаКоманд");
	КонецЦикла;
	
	А1Э_УниверсальнаяФорма.ДобавитьРеквизитыИЭлементы(Форма, МассивОписаний);

КонецФункции

#КонецЕсли
#Если Клиент Тогда
	
	Функция Переходы__ОбработчикКоманды(Форма, Команда) Экспорт
		ТипФормы = А1Э_Формы.ТипФормы(Форма);
		Ссылка = ТекущаяСсылка(Форма);
		Если НЕ ЗначениеЗаполнено(Ссылка) Тогда Возврат Неопределено; КонецЕсли;
		
		Настройки = А1Э_УниверсальнаяФорма.НастройкиКомпонента(Форма, Команда.Имя);
		А1Э_Общее.РезультатФункции(Настройки.Действие, Ссылка, Настройки.Объект, Настройки.ПолеОтбора);
	КонецФункции
	
	Функция Переходы__ДействиеПоУмолчанию(Ссылка, Объект, ПолеОтбора) Экспорт
		ПараметрыФормы = А1Э_Структуры.Создать(
		"Отбор", Новый Структура(ПолеОтбора, Ссылка)); 
		
		ОткрытьФорму(Объект + ".ФормаСписка", ПараметрыФормы);

	КонецФункции 
#КонецЕсли

#КонецОбласти

#Область ОповещениеОЗаписи

// Генерирует Оповещение (событие "А1Э_ЗаписьОбъекта") при записи объекта из его формы.
// 
// Возвращаемое значение:
//   - 
//
Функция ОповещениеОЗаписи__НастройкиМеханизма() Экспорт
	Настройки = А1Э_Механизмы.НовыйНастройкиМеханизма();
	
	Настройки.Обработчики.Вставить("ФормаЭлементаПослеЗаписи", Истина);
	
	Возврат Настройки;
КонецФункции

#Если Клиент Тогда
	Функция ОповещениеОЗаписи__ФормаЭлементаПослеЗаписи(Форма, ПараметрыЗаписи) Экспорт 
		Оповестить("А1Э_ЗаписьОбъекта", А1Э_Структуры.Создать(
		"Ссылка", Форма.Объект.Ссылка,
		), Форма);
	КонецФункции 
#КонецЕсли

#КонецОбласти

#Область Общее
#Если Клиент Тогда
	
	Функция ТекущаяСсылка(Форма) Экспорт
		ТипФормы = А1Э_Формы.ТипФормы(Форма);
		
		Если ТипФормы = "ФормаЭлемента" Тогда
			Ссылка = Форма.Объект.Ссылка;
		ИначеЕсли ТипФормы = "ФормаСписка" Тогда
			ТекущиеДанные = Форма.Элементы.Список.ТекущиеДанные;
			Если ТекущиеДанные = Неопределено Тогда
				Сообщить("Выберите строку списка, которая будет основанием для создания!");
				Возврат Неопределено;
			КонецЕсли;
			Ссылка = ТекущиеДанные.Ссылка;
		Иначе
			Возврат Неопределено;
		КонецЕсли;
		
		Возврат Ссылка;
	КонецФункции
	
#КонецЕсли
#Если НЕ Клиент Тогда
	
	Функция НовыйОписаниеКомандыМетаданных(Источник, ИмяМеханизма, ДействиеПоУмолчанию) 
		ОписаниеКоманды = Новый Структура("Объект,Имя,Заголовок,Действие");
		Если ТипЗнч(Источник) = Тип("Строка") Тогда
			ОписаниеКоманды.Объект = Источник;
		ИначеЕсли ТипЗнч(Источник) = Тип("Структура") Тогда
			ЗаполнитьЗначенияСвойств(ОписаниеКоманды, Источник);
			Если ОписаниеКоманды.Объект = Неопределено Тогда
				А1Э_Служебный.СлужебноеИсключение("В описании команды, связанной с метаданными, не указан основной объект!");
			КонецЕсли;
		Иначе
			А1Э_Служебный.СлужебноеИсключение("Неверный тип источника команды, связанной с метаданными. Ожидается Строка или Структура!");
		КонецЕсли;
		
		Если ОписаниеКоманды.Имя = Неопределено Тогда
			ОписаниеКоманды.Имя = СтрЗаменить(ОписаниеКоманды.Объект, ".", "__");
		КонецЕсли;
		Если ОписаниеКоманды.Действие = Неопределено Тогда
			ОписаниеКоманды.Действие = ДействиеПоУмолчанию;
		КонецЕсли;
		
		Возврат ОписаниеКоманды;
	КонецФункции
	
#КонецЕсли

Функция ИмяМодуля() Экспорт
	Возврат "А1Э_МеханизмыФорм";
КонецФункции

#КонецОбласти

