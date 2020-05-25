<?php

/***********************************************************************************
 *  Copyright © 2020 Joschi Kuphal <joschi@tollwerk.de>
 *
 *  All rights reserved
 *
 *  This script is part of the TYPO3 project. The TYPO3 project is
 *  free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  The GNU General Public License can be found at
 *  http://www.gnu.org/copyleft/gpl.html.
 *
 *  This script is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  This copyright notice MUST APPEAR in all copies of the script!
 ***********************************************************************************/

define('MODE_NONE', 0);
define('MODE_ADD', 1);
define('MODE_DELETE', 2);

$mode      = MODE_NONE;
$autoload  = 'autoload';
$namespace = null;
$directory = null;
$composer  = '/www/composer.json';

/**
 * Read the Composer configuration
 *
 * @return false|stdClass|string Composer configuration
 */
function fromComposerJson()
{
    $composerJson   = file_exists('/www/composer.json') ? file_get_contents('/www/composer.json') : '{}';
    $composerConfig = @json_decode($composerJson);

    return is_object($composerConfig) ? $composerConfig : new stdClass();
}

/**
 * Write the Composer configuration
 *
 * @param stdClass $composerConfig Composer configuration
 */
function toComposerJson(stdClass $composerConfig)
{
    file_put_contents(
        '/www/composer.json',
        json_encode($composerConfig, JSON_PRESERVE_ZERO_FRACTION | JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES)
    );
}

array_shift($argv);
foreach ($argv as $argument) {
    switch ($argument) {
        case '--add':
            $mode = MODE_ADD;
            break;
        case '--del':
            $mode = MODE_DELETE;
            break;
        case '--dev':
            $autoload .= '-dev';
            break;
        default:
            $argument = trim($argument, ' /\\');
            if (strlen($argument)) {
                if ($namespace === null) {
                    $namespace = strtr($argument, '/', '\\').'\\';
                } elseif ($directory === null) {
                    $directory = $argument.'/';
                }
            }
    }
}

// If an entry should be added
if (($mode === MODE_ADD) && ($namespace !== null) && ($directory !== null)) {
    $composerConfig                   = fromComposerJson();
    $autoloadConfig                   = $composerConfig->{$autoload} ?? new stdClass();
    $autoloadConfigPsr4               = $autoloadConfig->{'psr-4'} ?? new stdClass();
    $autoloadConfigPsr4->{$namespace} = $directory;
    $autoloadConfig->{'psr-4'}        = $autoloadConfigPsr4;
    $composerConfig->{$autoload}      = $autoloadConfig;
    toComposerJson($composerConfig);
}

// If an entry should be removed
if (($mode === MODE_DELETE) && ($namespace !== null)) {
    $composerConfig = fromComposerJson();
    if (isset($composerConfig->{$autoload})) {
        $autoloadConfig                   = $composerConfig->{$autoload};
        if (isset($autoloadConfig->{'psr-4'})) {
            unset($autoloadConfig->{'psr-4'}->{$namespace});
            if (!count(get_object_vars($autoloadConfig->{'psr-4'}))) {
                unset($autoloadConfig->{'psr-4'});
            }
            if (!count(get_object_vars($autoloadConfig))) {
                unset($composerConfig->{$autoload});
            } else {
                $composerConfig->{$autoload} = $autoloadConfig;
            }
        }
        toComposerJson($composerConfig);
    }
}

exit(0);
