import datetime
from ..config.constants import DIRECTION, START_YEAR, NUM_YEARS, FORWARD, BACKWARD

def get_interval_start_to_end_dates(start_year=START_YEAR, num_years=NUM_YEARS, direction=DIRECTION):
    """
    Calculate start and end dates for a time interval over multiple years, in either direction.

    Parameters:
        start_year (int): Anchor year (starting point).
        num_years (int): Number of years to span, including anchor.
        direction (str): FORWARD ("forward") or BACKWARD ("backward").

    Returns:
        tuple: (start_date, end_date) formatted as ('YYYY-MM-DD', 'YYYY-MM-DD').

    Logic:
        - FORWARD: Interval runs from start_year up to min(start_year + num_years - 1, current year)
        - BACKWARD: Interval runs from start_year down to max(start_year - num_years + 1, 1940)
        - End date is capped at today's date if interval would cross into the future.
    
    Examples:
        # Forward (default config): 2015, 5 years → 2015-01-01 to 2019-12-31
        get_interval_start_to_end_dates() 
        # Forward: 2020, 3 years → 2020-01-01 to 2022-12-31
        get_interval_start_to_end_dates(2020, 3, FORWARD)
        # Backward: 2025, 2 years → 2025-01-01 to 2024-12-31
        get_interval_start_to_end_dates(2025, 2, BACKWARD)
    """
    today = datetime.date.today()

    if direction == FORWARD:
        start_date = datetime.date(start_year, 1, 1)
        end_year = min(start_year + num_years - 1, today.year)
        # End date is today if the interval covers the current year, else Dec 31 of last year in interval
        if end_year == today.year:
            end_date = today
        else:
            end_date = datetime.date(end_year, 12, 31)
    elif direction == BACKWARD:
        end_year = max(start_year - num_years + 1, 1940)  # Open-Meteo limit (earliest year)
        start_date = datetime.date(start_year, 1, 1)
        end_date = datetime.date(end_year, 12, 31)
        # If end_date is later than today (possible only if start_year > today.year)
        if end_date > today:
            end_date = today
    else:
        raise ValueError("direction must be FORWARD or BACKWARD")

    return start_date.strftime("%Y-%m-%d"), end_date.strftime("%Y-%m-%d")
