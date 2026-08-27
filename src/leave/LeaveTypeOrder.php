<?php

class LeaveTypeOrder
{
    private const ORDER = [
        'Vacation Leave' => 1,
        'Sick Leave' => 2,
        'Paternity Leave' => 3,
        'Maternity Leave' => 4,
        'Bereavement Leave' => 5,
    ];

    public static function sortNames(array $names): array
    {
        usort($names, function ($left, $right) {
            $leftOrder = self::ORDER[$left] ?? PHP_INT_MAX;
            $rightOrder = self::ORDER[$right] ?? PHP_INT_MAX;

            return $leftOrder <=> $rightOrder;
        });

        return $names;
    }

    public static function sortTypes(array $items, string $nameKey): array
    {
        usort($items, function ($left, $right) use ($nameKey) {
            $leftName = $left[$nameKey] ?? '';
            $rightName = $right[$nameKey] ?? '';

            $leftOrder = self::ORDER[$leftName] ?? PHP_INT_MAX;
            $rightOrder = self::ORDER[$rightName] ?? PHP_INT_MAX;

            return $leftOrder <=> $rightOrder;
        });

        return $items;
    }
}
