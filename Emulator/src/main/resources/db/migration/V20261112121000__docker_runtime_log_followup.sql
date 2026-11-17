UPDATE `emulator_settings`
SET `value` = '/data/generated/badgeparts'
WHERE `key` = 'imager.location.output.badges';

INSERT IGNORE INTO `emulator_texts` (`key`, `value`)
VALUES
    ('commands.keys.cmd_roomfx', 'roomfx'),
    ('commands.error.cmd_roomfx.unknown', 'Effects: rotate, shake, zoom, disco.');

-- These rows are unlimited catalogue items, so a non-zero limited_sells
-- value is invalid when limited_stack is zero.
UPDATE `catalog_items`
SET `limited_sells` = 0
WHERE `limited_stack` = 0
  AND `limited_sells` > 0;
