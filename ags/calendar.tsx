import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"

export default function CalendarWindow() {
  const { TOP, RIGHT } = Astal.WindowAnchor

  return (
    <window
      name="calendar"
      class="CalendarWindow"
      visible={false}
      application={app}
      anchor={TOP | RIGHT}
      layer={Astal.Layer.TOP}
      marginTop={8}
      marginRight={8}
    >
      <box class="calendar-box">
        <Gtk.Calendar />
      </box>
    </window>
  )
}
