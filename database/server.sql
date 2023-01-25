
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `server`
--

-- --------------------------------------------------------

--
-- Структура таблицы `gangs`
--

CREATE TABLE `gangs` (
  `id` int NOT NULL,
  `name` varchar(50) NOT NULL,
  `color` varchar(9) NOT NULL,
  `CreateAt` varchar(30) NOT NULL,
  `ID_GI` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Структура таблицы `permissions`
--

CREATE TABLE `permissions` (
  `id` int NOT NULL,
  `BAN` tinyint(1) NOT NULL DEFAULT '0',
  `KICK` tinyint(1) NOT NULL DEFAULT '0',
  `MUTE` tinyint(1) NOT NULL DEFAULT '0',
  `EXPLODE` tinyint(1) NOT NULL DEFAULT '0',
  `SLAP` tinyint(1) NOT NULL DEFAULT '0',
  `HEAL` tinyint(1) NOT NULL DEFAULT '0',
  `KILL1` tinyint(1) NOT NULL DEFAULT '0',
  `EJECT` tinyint(1) NOT NULL DEFAULT '0',
  `GOTO` tinyint(1) NOT NULL DEFAULT '0',
  `GET1` tinyint(1) NOT NULL DEFAULT '0',
  `RESPAWN` tinyint(1) NOT NULL DEFAULT '0',
  `FREEZE` tinyint(1) NOT NULL DEFAULT '0',
  `DCARS` tinyint(1) NOT NULL DEFAULT '0',
  `SPECTATE` tinyint(1) NOT NULL DEFAULT '0',
  `BURN` tinyint(1) NOT NULL DEFAULT '0',
  `TAKEGUNS` tinyint(1) NOT NULL DEFAULT '0',
  `GIVEWEAPON` tinyint(1) NOT NULL DEFAULT '0',
  `CHECK1` tinyint(1) NOT NULL DEFAULT '0',
  `ACHAT` tinyint(1) NOT NULL DEFAULT '0',
  `PR_ID` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Структура таблицы `players`
--

CREATE TABLE `players` (
  `id` int NOT NULL,
  `name` varchar(24) NOT NULL,
  `password` varchar(145) NOT NULL,
  `ip` varchar(40) NOT NULL,
  `gpci` varchar(41) NOT NULL,
  `cash` int NOT NULL DEFAULT '0',
  `skin` int NOT NULL,
  `color` int NOT NULL,
  `chatcolor` int NOT NULL DEFAULT '0',
  `gang` int NOT NULL DEFAULT '0',
  `rang` int NOT NULL DEFAULT '0',
  `invitetime` int NOT NULL DEFAULT '0',
  `SpawnX` float NOT NULL DEFAULT '0',
  `SpawnY` float NOT NULL DEFAULT '0',
  `SpawnZ` float NOT NULL DEFAULT '0',
  `SpawnR` float NOT NULL DEFAULT '0',
  `SpawnInt` int NOT NULL DEFAULT '0',
  `time` int NOT NULL DEFAULT '12',
  `weather` int NOT NULL DEFAULT '1',
  `changenametime` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Структура таблицы `settings`
--

CREATE TABLE `settings` (
  `id` int NOT NULL,
  `cammode` int NOT NULL DEFAULT '0',
  `autorepair` int NOT NULL DEFAULT '1',
  `collision` int NOT NULL DEFAULT '1',
  `godmode` int NOT NULL DEFAULT '1',
  `invite` int NOT NULL DEFAULT '1',
  `nicknames` int NOT NULL DEFAULT '1',
  `sms` int NOT NULL DEFAULT '1',
  `teleport` int NOT NULL DEFAULT '0',
  `button` int NOT NULL DEFAULT '0',
  `ID_S` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- --------------------------------------------------------

--
-- Структура таблицы `teleports`
--

CREATE TABLE `teleports` (
  `id` int NOT NULL,
  `X` float NOT NULL,
  `Y` float NOT NULL,
  `Z` float NOT NULL,
  `R` float NOT NULL,
  `Interior` int NOT NULL,
  `Name` varchar(51) NOT NULL,
  `ID_TP` int NOT NULL,
  `CreateAt` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `gangs`
--
ALTER TABLE `gangs`
  ADD PRIMARY KEY (`ID_GI`);

--
-- Индексы таблицы `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`PR_ID`);

--
-- Индексы таблицы `players`
--
ALTER TABLE `players`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`ID_S`);

--
-- Индексы таблицы `teleports`
--
ALTER TABLE `teleports`
  ADD PRIMARY KEY (`ID_TP`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `gangs`
--
ALTER TABLE `gangs`
  MODIFY `ID_GI` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT для таблицы `permissions`
--
ALTER TABLE `permissions`
  MODIFY `PR_ID` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT для таблицы `players`
--
ALTER TABLE `players`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT для таблицы `settings`
--
ALTER TABLE `settings`
  MODIFY `ID_S` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT для таблицы `teleports`
--
ALTER TABLE `teleports`
  MODIFY `ID_TP` int NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
