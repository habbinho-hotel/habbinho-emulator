# Earnings Center Packet Contract

This document describes the packet layout and server behavior used by Octane's
Earnings view. The server determines eligibility, reward amounts, and cooldowns.

## Incoming

### `RequestEarningsCenterEvent`

- Header: `9308`
- Body: empty
- Response: `EarningsCenterComposer`

### `ClaimEarningsRewardEvent`

- Header: `9309`
- Body:
  - `String categoryKey`
- Response: `EarningsClaimResultComposer`

### `ClaimAllEarningsRewardsEvent`

- Header: `9310`
- Body: empty
- Response: `EarningsClaimResultComposer`

## Outgoing

### `EarningsCenterComposer`

- Header: `9407`
- Body:
  - `int entryCount`
  - repeated entry:
    - `String categoryKey`
    - `boolean enabled`
    - `boolean claimable`
    - `int nextClaimAt`
    - `int rewardCount`
    - repeated reward:
      - `String type`
      - `int amount`
      - `int pointsType`
      - `String data`

`nextClaimAt` is a Unix timestamp in seconds. `0` means the server did not send a timer.

### `EarningsClaimResultComposer`

- Header: `9408`
- Body:
  - `int resultCount`
  - repeated result:
    - `String categoryKey`
    - `String status`
    - `boolean success`
    - `boolean hasEntry`
    - entry body when `hasEntry=true`, same shape as `EarningsCenterComposer`

## Categories

- `daily_gift`
- `games`
- `achievements`
- `marketplace`
- `hc_payday`
- `level_progress`
- `donations`
- `bonus_bag`
- `mystery_boxes`
- `club_job`
- `agency`

See [EarningsCategory](../Emulator/src/main/java/polaris/hotel/earnings/EarningsCategory.java)
for the registered keys.

## Reward Types

- `credits`
- `pixels`
- `points`
- `badge`
- `item`
- `hc_days`

For `points`, `pointsType` carries the currency type. For `badge`, `data` carries the badge code. For `item`, `data` carries the `items_base.id`. Other reward types keep `data` empty.

Native rows use existing server state:

- `marketplace`: sold marketplace offers waiting for payout
- `hc_payday`: unclaimed rows in `logs_hc_payday`
- `games` and `agency`: unclaimed Wired credits for categories 11 and 13, respectively

`achievements` and `level_progress` use configured rewards. Their native
eligibility checks use achievement score buckets and citizenship/helper talent levels.

## Result Status

- `success`
- `disabled`
- `unknown_category`
- `already_claimed`
- `no_reward`
- `error`

See [the composer](../Emulator/src/main/java/polaris/messages/outgoing/earnings/EarningsCenterComposer.java)
and [claim result composer](../Emulator/src/main/java/polaris/messages/outgoing/earnings/EarningsClaimResultComposer.java)
for serialization, and [EarningsCenterManagerTest](../Emulator/src/test/java/polaris/hotel/earnings/EarningsCenterManagerTest.java)
for claim behavior.
