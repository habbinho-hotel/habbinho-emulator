-- The bundled Octane client uploads camera PNGs. Server-side rendering needs
-- asset libraries that are not part of this Docker installation.
UPDATE `emulator_settings`
SET `value` = 'upload'
WHERE `key` = 'camera.render.mode'
  AND `value` = 'server';

INSERT IGNORE INTO `emulator_texts` (`key`, `value`)
VALUES ('commands.error.cmd_dance.usage', 'Usage: :dance <0-4>');

-- The legacy citizenship row referenced a removed achievement and had two
-- levels for one achievement. Keep its rewards, but make the level task-free
-- until a valid achievement is configured.
UPDATE `achievements_talents`
SET `achievement_ids` = '',
    `achievement_levels` = ''
WHERE `type` = 'citizenship'
  AND `level` = 2
  AND `achievement_ids` = '445'
  AND `achievement_levels` = '2,1';
