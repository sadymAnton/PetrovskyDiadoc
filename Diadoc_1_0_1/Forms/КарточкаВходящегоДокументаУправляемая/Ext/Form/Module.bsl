﻿&НаСервере
Перем мОбработкаОбъект;
Перем МодульОбработкаВходящих;

&НаКлиенте
Перем ОсновнаяФорма;

//{		Сервисные методы
	

// Заглушка для совместимости с управляемыми формами	
&НаСервере
Функция ОбработкаОбъект()
	
	Если мОбработкаОбъект=Неопределено Тогда
		мОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	КонецЕсли;
	
	Возврат мОбработкаОбъект;
	
КонецФункции
	
&НаКлиенте
Функция ОсновнаяФорма() Экспорт

	Если ОсновнаяФорма = Неопределено Тогда
		ОсновнаяФорма= ВладелецФормы.ОсновнаяФорма();
	КонецЕсли;	
	
	Возврат ОсновнаяФорма;
	
КонецФункции

&НаСервере
Функция ЭтоУправляемаяФорма()
	
	Возврат (СтрДлина(ТипЗнч(ЭтаФорма))>5);
	
КонецФункции

//}		Сервисные методы


//{	ИНТЕРФЕЙСНЫЕ ОБРАБОТЧИКИ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Параметры.Свойство("МодульОбработкаВходящих", МодульОбработкаВходящих);
	Параметры.Свойство("параметрыНачалаОбработки", параметрыНачалаОбработки);
	
	ОбработкаОбъект().ЭДО_ЗаполнитьРеквизитыФормыВходящегоДокумента(ЭтаФорма, Параметры.ДокументДД, Параметры.ПакетДД);
	ЗаполнитьЗакладкуОтветаПоДокументуНаСервере();
	УправлениеВидимостьюКнопок();
	
	Попытка
		СформироватьПечатнуюФормуНаСервере();
	Исключение
		Сообщить("Не удалось визуализировать печатную форму документа по причине:" + Символы.ПС + ОписаниеОшибки());
	КонецПопытки;
	
КонецПроцедуры

&НаКлиенте
Процедура НадписьОткрытьВБраузереНажатие(Элемент)
	
	ГиперссылкаНаДокумент = СсылкаВБраузереНаДокументНаСервере(Параметры.ДокументДД);
	Если ЗначениеЗаполнено(ГиперссылкаНаДокумент) Тогда
		ЗапуститьПриложение(ГиперссылкаНаДокумент);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Функция СсылкаВБраузереНаДокументНаСервере(ДокументДД)
	Возврат ОбработкаОбъект().ЭДО_Документ_СсылкаВБраузере(Параметры.ДокументДД);
КонецФункции

&НаСервере
Процедура ЗаполнитьВариантыОтветныхДействийПоДокументуНаСервере(ВариантыОтветныхДействий)
	
	Элементы.Вердикт.СписокВыбора.Очистить();
	Список= Новый СписокЗначений;
	Для Каждого Эл Из ВариантыОтветныхДействий Цикл
		Элементы.Вердикт.СписокВыбора.Добавить(Эл.Значение, Эл.Представление);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьЗакладкуОтветаПоДокументуНаСервере()
	
	ДокументДД= Параметры.ДокументДД;
	ПакетДД= Параметры.ПакетДД;
	
	мДеревоКонтента= РеквизитФормыВЗначение("ДеревоКонтента", Тип("ДеревоЗначений"));
	
	ВариантыОтветныхДействий = ОбработкаОбъект().ЭДО_ВариантыОтветныхДействийПоДокументу(ДокументДД);  // Отказать / Уточнить / Подписать
	ЗаполнитьВариантыОтветныхДействийПоДокументуНаСервере(ВариантыОтветныхДействий);
	
	ДанныеОтвета = ОбработкаОбъект().ЭДО_ПолучитьСохраненныеДанныеДляОтправкиОтвета(ДокументДД, ПакетДД);
	
	Если ДанныеОтвета = Неопределено
		Или Не ЗначениеЗаполнено(ДанныеОтвета.Вердикт) Тогда
		// ответ не сохранялся либо уже был отправлен
		Возврат;
	КонецЕсли;
	
	Вердикт				= ДанныеОтвета.Вердикт;
	
	КонтентОтвета = ОбработкаОбъект().ЭДО_ПолучитьПустойКонтентОтвета(ОбработкаОбъект().ЭДО_ПолучитьТипВходящегоДокумента(ДокументДД), Вердикт);
	мДеревоКонтента = ОбработкаОбъект().ЭДО_КонтентОтветаВДеревоЗначений(КонтентОтвета);
	
	ОбработкаОбъект().ЭДО_ЗаполнитьДеревоЗначенийПоСтруктуре(ДанныеОтвета.СтруктураОтвета, мДеревоКонтента);

	ЗначениеВРеквизитФормы(мДеревоКонтента, "ДеревоКонтента");
	
	//Элементы.СтраницаОтветНаДокумент.Доступность= (Элементы.Вердикт.СписокВыбора.Количество()>0);	
	
КонецПроцедуры

&НаКлиенте
Процедура РазвернутьСтрокиДереваЗначений(ДеревоИлиСтрока)
	
	//Для Каждого СтрокаДерева Из ДеревоИлиСтрока.ПолучитьЭлементы() Цикл
	//Для Каждого СтрокаДерева Из ДеревоКонтента.ПолучитьЭлементы() Цикл
	//	Элементы.ДеревоКонтента.Развернуть(СтрокаДерева, Истина);
	//	//РазвернутьСтрокиДереваЗначений(СтрокаДерева);
	//КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ВердиктПриИзменении(Элемент)
	
	ДеревоКонтента.ПолучитьЭлементы().Очистить();
	Если ЗначениеЗаполнено(Вердикт) Тогда
		ВердиктПриИзмененииНаСервере();
		РазвернутьСтрокиДереваЗначений(Элементы.ДеревоКонтента);
	КонецЕсли;
	УстановитьДоступностьКнопокРаботыСОтветом();
	
КонецПроцедуры

&НаСервере
Процедура ВердиктПриИзмененииНаСервере()
	
	ТипВходящегоДокумента = ОбработкаОбъект().ЭДО_ПолучитьТипВходящегоДокумента(Параметры.ДокументДД);
	КонтентОтвета = ОбработкаОбъект().ЭДО_ПолучитьПустойКонтентОтвета(ТипВходящегоДокумента, Вердикт);
	мДеревоКонтента = ОбработкаОбъект().ЭДО_КонтентОтветаВДеревоЗначений(КонтентОтвета);
	ЗначениеВРеквизитФормы(мДеревоКонтента, "ДеревоКонтента");
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьДоступностьКнопокРаботыСОтветом()
	
	Элементы.ОтправитьОтвет.Доступность		= СтатусДокументаПредполагаетОтвет(Статус) и ЗначениеЗаполнено(Вердикт);
	Элементы.СохранитьОтвет.Доступность		= СтатусДокументаПредполагаетОтвет(Статус) и ЗначениеЗаполнено(Вердикт);
	Элементы.Вердикт.Доступность			= СтатусДокументаПредполагаетОтвет(Статус);
	Элементы.ДеревоКонтента.ТолькоПросмотр	= НЕ СтатусДокументаПредполагаетОтвет(Статус);
	
КонецПроцедуры

&НаКлиенте
Функция СтатусДокументаПредполагаетОтвет(Статус)
	
	Возврат
		Статус <> "Подписан"
		И Статус <> "В подписи отказано"
		И Статус <> "Ожидается уточнение";
		
КонецФункции

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	//мауз
	мОснФорм = ОсновнаяФорма();
	Если мОснФорм <> неопределено Тогда
		мОснФорм.ПоказатьКнопкуВыпадающегоСписка_83(Элементы.Вердикт);
	КонецЕсли;	
	РазвернутьСтрокиДереваЗначений(Элементы.ДеревоКонтента);
	Если Элементы.Вердикт.СписокВыбора.НайтиПоЗначению(Вердикт)=Неопределено Тогда
		Вердикт = Неопределено;
	КонецЕсли;
	УстановитьДоступностьКнопокРаботыСОтветом();
	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьДокумент(Команда)
	
	СоздатьДокументНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура СоздатьДокументНаСервере()
	
	РезультатФункции = ОбработкаОбъект().СоздатьИСопоставитьДокументДД(Параметры.ДокументДД, Параметры.ПакетДД);
	ОбработкаОбъект().ОбработатьРезультатФункции(РезультатФункции);
	
	ОбработкаОбъект().ЭДО_ЗаполнитьРеквизитыФормыВходящегоДокумента(ЭтаФорма, Параметры.ДокументДД, Параметры.ПакетДД);
	УправлениеВидимостьюКнопок();
	
КонецПроцедуры

&НаКлиенте
Процедура СопоставитьДокумент(Команда)
	
	СопоставитьДокументНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура СопоставитьДокументНаСервере()
	
	Действие = ?(ЗначениеЗаполнено(ДокументВ1С), "Отвязать", "Сопоставить");
	
    Если Действие = "Отвязать" Тогда
		
		ОбработкаОбъект().ОтменитьСопоставлениеДокументаДД(Параметры.ДокументДД);
		
	Иначе
		
		РезультатФункции = ОбработкаОбъект().НайтиИСопоставитьДокументДД(Параметры.ДокументДД, Параметры.ПакетДД);
		ОбработкаОбъект().ОбработатьРезультатФункции(РезультатФункции);
		
	КонецЕсли;
	
	ОбработкаОбъект().ЭДО_ЗаполнитьРеквизитыФормыВходящегоДокумента(ЭтаФорма, Параметры.ДокументДД, Параметры.ПакетДД);
	УправлениеВидимостьюКнопок();
	
КонецПроцедуры

&НаКлиенте
Процедура КомандаОтправитьОтвет(Команда)
	
	ОписаниеОповещения = ОсновнаяФорма().НовыйОписаниеОповещения("ОтправитьОтвет", ЭтаФорма, Неопределено);
	ОсновнаяФорма().ВыполнитьДействиеПослеАвторизации(ОписаниеОповещения);
	
КонецПроцедуры

&НаСервере
Функция ПодготовитьДанныеДляОтправкиНаСервере()
	
	мДеревоКонтента= РеквизитФормыВЗначение("ДеревоКонтента", Тип("ДеревоЗначений"));
	СтруктураОтвета = ОбработкаОбъект().ЭДО_ДеревоЗначенийВСтруктуру(мДеревоКонтента);
	ОбработкаОбъект().ЭДО_СохранитьОтветПоДокументу(Параметры.ДокументДД, Вердикт, СтруктураОтвета);
	Возврат ОбработкаОбъект().ЭДО_ПолучитьСохраненныеДанныеДляОтправкиОтвета(Параметры.ДокументДД, Параметры.ПакетДД);
	
КонецФункции

&НаСервере
Процедура ОбновитьСтатусыИФормуНаСервере(ЗНАЧ НовыйСтатус)
	
	ОбработкаОбъект().ЭДО_УстановитьСтатусДокумента(Параметры.ДокументДД, НовыйСтатус);
	ОбработкаОбъект().ЭДО_ЗаполнитьРеквизитыФормыВходящегоДокумента(ЭтаФорма, Параметры.ДокументДД, Параметры.ПакетДД);
	ЗаполнитьЗакладкуОтветаПоДокументуНаСервере();
	
КонецПроцедуры

//}	ИНТЕРФЕЙСНЫЕ ОБРАБОТЧИКИ

&НаКлиенте
Процедура ОтправитьОтвет(П1=Неопределено, П2=Неопределено) Экспорт
	
	ДанныеОтправки= ПодготовитьДанныеДляОтправкиНаСервере();
	
	Если НЕ ЗначениеЗаполнено(ДанныеОтправки) Тогда
		Сообщить("Ответ не подготовлен");
		Возврат;
	КонецЕсли;
	
	ОшибкаПодписания= ОсновнаяФорма().Модуль_РаботаСКомпонентой().ОтправитьОтветНаДокумент(ДанныеОтправки.Идентификаторы, ДанныеОтправки.ВидОтвета, ДанныеОтправки.СтруктураОтвета);
	
	Если Не ЗначениеЗаполнено(ОшибкаПодписания) Тогда
		Сообщить("Ответ успешно отправлен");
		ОбновитьСтатусыИФормуНаСервере(ДанныеОтправки.НовыйСтатус);
	Иначе
		Сообщить("Отправка ответа не удалась по причине:" + Символы.ПС + ОшибкаПодписания);
	КонецЕсли;
	
	УстановитьДоступностьКнопокРаботыСОтветом();
	
КонецПроцедуры

&НаСервере
Процедура УправлениеВидимостьюКнопок()
	
	Если ЗначениеЗаполнено(ДокументВ1С) Тогда
		Элементы.СопоставитьДокумент.Заголовок = "Отвязать";
		Элементы.СоздатьДокумент.Доступность = Ложь;
	Иначе
		Элементы.СопоставитьДокумент.Заголовок = "Сопоставить";
		Элементы.СоздатьДокумент.Доступность = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СохранитьОтвет(Команда)
	СохранитьОтветНаСервере();
КонецПроцедуры

&НаСервере
Процедура СохранитьОтветНаСервере()
	
	мДеревоКонтента= РеквизитФормыВЗначение("ДеревоКонтента", Тип("ДеревоЗначений"));
	СтруктураОтвета = ОбработкаОбъект().ЭДО_ДеревоЗначенийВСтруктуру(мДеревоКонтента);
	ОбработкаОбъект().ЭДО_СохранитьОтветПоДокументу(Параметры.ДокументДД, Вердикт, СтруктураОтвета);
	
КонецПроцедуры

&НаСервере
Функция ОшибкиДокументаСтрокой(ДокументДД)
	
	МассивОшибок = ОбработкаОбъект().ЭДО_МассивОшибокВалидацииДокумента(ДокументДД);
	Результат = ОбработкаОбъект().ЭДО_Служебные_МассивВСтроку(МассивОшибок, Символы.ПС);
	
	Возврат Результат;
	
КонецФункции	

&НаСервере
Процедура СформироватьПечатнуюФормуНаСервере()
	
	ОписаниеТипаДокумента = ОбработкаОбъект().ЭДО_ОписаниеТипаДокумента(Тип);
	Если Не ОписаниеТипаДокумента.Формализованный Тогда
		Элементы.ГруппаПечатнаяФорма.Видимость = Ложь;
		Возврат;
	Иначе
		ИмяКонтента = ОписаниеТипаДокумента.СтруктураСодержимого;
	КонецЕсли;
	
	ТабДок = ОбработкаОбъект().ЭДО_ПолучитьПечатнуюФормуЭлектронногоДокумента(Параметры.ДокументДД);
	Если ТипЗнч(ТабДок) = Тип("ТабличныйДокумент") Тогда
		ПечатнаяФормаДокумента.Вывести(ТабДок);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВердиктОчистка(Элемент, СтандартнаяОбработка)

	УстановитьДоступностьКнопокРаботыСОтветом();
	ДеревоКонтента.ПолучитьЭлементы().Очистить();

КонецПроцедуры

&НаКлиенте
Процедура ОтправитьВОбработку(Команда)
	
	ПараметрыОбработки = Новый Структура("параметрыНачалаОбработки", параметрыНачалаОбработки);
	ОткрытьФорму("ВнешняяОбработка.Диадок_ОбработкаВходящихДокументов.Форма.ОтправитьВОбработку", ПараметрыОбработки, ЭтаФорма);
	
КонецПроцедуры

&НаСервере
Процедура ИгнорироватьНаСервере()
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаКлиенте
Процедура Игнорировать(Команда)
	ИгнорироватьНаСервере();
КонецПроцедуры
