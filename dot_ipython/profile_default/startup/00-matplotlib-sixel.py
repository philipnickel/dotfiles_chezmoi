import importlib.util
import matplotlib


def _enable_sixel_backend() -> None:
    """Try to switch Matplotlib to the Sixel backend when available."""

    # Bail out quickly if the sixel module is not installed.
    if importlib.util.find_spec("sixel") is None:
        return

    try:
        matplotlib.use("module://sixel.sixel")
    except Exception:
        # Keep Matplotlib's default backend when Sixel cannot be initialised.
        pass


_enable_sixel_backend()

del _enable_sixel_backend
