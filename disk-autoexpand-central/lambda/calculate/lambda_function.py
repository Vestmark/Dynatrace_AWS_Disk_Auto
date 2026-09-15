import math


def lambda_handler(event, context):
    current = int(event.get("CurrentSizeGiB", 0))
    percent = int(event.get("ExpandPercent", 15))

    if current <= 0:
        raise ValueError(
            f"Invalid current volume size: {current}"
        )

    if percent <= 0:
        raise ValueError(
            f"Invalid expansion percentage: {percent}"
        )

    percentage_size = math.ceil(
        current * (1 + percent / 100)
    )

    minimum_size = current + 20

    new_size = max(
        percentage_size,
        minimum_size
    )

    return {
        "CurrentSizeGiB": current,
        "ExpandPercent": percent,
        "NewSizeGiB": new_size
    }