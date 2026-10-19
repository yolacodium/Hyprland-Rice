import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import { For, createBinding } from "ags"
import Notifd from "gi://AstalNotifd"

export default function NotificationCenter() {
  const notifd = Notifd.get_default()
  const notifications = createBinding(notifd, "notifications")
  const { TOP, RIGHT } = Astal.WindowAnchor

  return (
    <window
      name="notification-center"
      class="NotificationCenter"
      application={app}
      visible={false}
      anchor={TOP | RIGHT}
      marginTop={10}
      marginRight={10}
      keymode={Astal.Keymode.ON_DEMAND}
    >
      <box class="nc-box" orientation={Gtk.Orientation.VERTICAL} spacing={8} widthRequest={380}>
        <box class="nc-header" spacing={8}>
          <label class="nc-title" label="Benachrichtigungen" hexpand halign={Gtk.Align.START} />
          <button
            class="nc-clear"
            onClicked={() => notifd.get_notifications().forEach((n) => n.dismiss())}
          >
            <label label="Alle löschen" />
          </button>
        </box>

        <Gtk.ScrolledWindow vexpand heightRequest={450}>
          <box orientation={Gtk.Orientation.VERTICAL} spacing={6}>
            <For each={notifications}>
              {(n) => (
                <box class="nc-item" orientation={Gtk.Orientation.VERTICAL} spacing={2}>
                  <box>
                    <label class="nc-app" label={n.appName} hexpand halign={Gtk.Align.START} />
                    <button class="nc-close" onClicked={() => n.dismiss()}>
                      <label label="✕" />
                    </button>
                  </box>
                  <label class="nc-summary" label={n.summary} halign={Gtk.Align.START} wrap />
                  <label class="nc-body" label={n.body} halign={Gtk.Align.START} wrap visible={!!n.body} />
                </box>
              )}
            </For>
          </box>
        </Gtk.ScrolledWindow>
      </box>
    </window>
  )
}