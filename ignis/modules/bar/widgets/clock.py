import datetime
from ignis import widgets
from ignis.window_manager import WindowManager
from ignis import utils
from ignis.variable import Variable
from ignis.services.network import NetworkService
from ignis.services.notifications import NotificationService
from ignis.services.recorder import RecorderService
from ignis.services.audio import AudioService
from ..indicator_icon import IndicatorIcon, NetworkIndicatorIcon
from ignis.options import options

network = NetworkService.get_default()
notifications = NotificationService.get_default()
recorder = RecorderService.get_default()
audio = AudioService.get_default()

window_manager = WindowManager.get_default()

current_time = Variable(
    value=utils.Poll(1000, lambda x: datetime.datetime.now().strftime("%H:%M:%S")).bind(
        "output"
    )
)


class Clock(widgets.Box):
    def __init__(self):
        super().__init__(
            css_classes=["clock", "unset"],
            child=[
                widgets.Label(
                    label=current_time.bind("value"),
                ),
            ]
       )
