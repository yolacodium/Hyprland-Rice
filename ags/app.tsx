import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { createPoll } from "ags/time"
import { readFile, monitorFile } from "ags/file"
import { execAsync, subprocess } from "ags/process"
import { createBinding, createState, For, With } from "ags"
import GLib from "gi://GLib"
import Hyprland from "gi://AstalHyprland"
import Mpris from "gi://AstalMpris"
import Notifd from "gi://AstalNotifd"
import NotificationCenter from "./NotificationCenter"
import CalendarWindow from "./calendar"
import Wp from "gi://AstalWp"

function Volume() {
  const speaker = Wp.get_default()!.audio.defaultSpeaker

  return (
    <menubutton
  class="pill volume-btn"
  tooltipText={createBinding(speaker, "volume")((v) => `${Math.round(v * 100)}%`)}
>
      <box spacing={6}>
        <image iconName={createBinding(speaker, "volumeIcon")} />
        <label
          label={createBinding(speaker, "volume")((v) => `${Math.round(v * 100)}%`)}
        />
      </box>
      <popover>
        <box class="volume-popover" spacing={8}>
          <button
            class="pbtn"
            onClicked={() => (speaker.mute = !speaker.mute)}
          >
            <image iconName={createBinding(speaker, "volumeIcon")} />
          </button>
          <Gtk.Scale
            widthRequest={160}
            $={(self) => {
              self.set_range(0, 1)
              self.set_value(speaker.volume)
              self.connect("value-changed", () => {
                if (Math.abs(self.get_value() - speaker.volume) > 0.005)
                  speaker.volume = self.get_value()
              })
              speaker.connect("notify::volume", () => self.set_value(speaker.volume))
            }}
          />
        </box>
      </popover>
    </menubutton>
  )
}



const dir = GLib.get_user_config_dir() + "/ags"
const loadCss = () =>
  app.apply_css(readFile(`${dir}/colors.css`) + readFile(`${dir}/style.css`), true)

// ---- Cava: einmal global starten, nicht pro Monitor ----
const BAR_COUNT = 16
const [cavaBars, setCavaBars] = createState<number[]>(Array(BAR_COUNT).fill(0))

subprocess(
  ["cava", "-p", `${dir}/cava.ags.conf`],
  (line) => {
    const vals = line.split(";").filter(Boolean).map(Number)
    if (vals.length) setCavaBars(vals)
  },
  (err) => console.error(err),
)

function Cava() {
  return (
    <box class="pill cava" spacing={3} valign={Gtk.Align.CENTER}>
      {Array.from({ length: BAR_COUNT }, (_, i) => (
        <box
          class="cava-bar"
          valign={Gtk.Align.END}
          widthRequest={5}
          heightRequest={cavaBars((b) => 4 + (b[i] ?? 0) * 3)}
        />
      ))}
    </box>
  )
}

function Workspaces() {
  const hypr = Hyprland.get_default()
  const workspaces = createBinding(hypr, "workspaces")
  const focused = createBinding(hypr, "focusedWorkspace")

  return (
    <box class="pill">
      <For each={workspaces((ws) => ws.filter((w) => w.id > 0).sort((a, b) => a.id - b.id))}>
        {(ws) => (
          <button
            class={focused((f) => (f?.id === ws.id ? "ws active" : "ws"))}
            onClicked={() => ws.focus()}
          >
            <label label={String(ws.id)} />
          </button>
        )}
      </For>
    </box>
  )
}

function Media() {
  const mpris = Mpris.get_default()
  const players = createBinding(mpris, "players")

  return (
    <box class="pill">
      <With value={players((p) => p[0])}>
        {(player) =>
          player ? (
            <label label={createBinding(player, "title")} maxWidthChars={40} />
          ) : (
            <label label="Nichts läuft" />
          )
        }
      </With>
    </box>
  )
}

function NotifButton() {
  const notifd = Notifd.get_default()
  const notifications = createBinding(notifd, "notifications")

  return (
    <button
      class="pill notif-btn"
      onClicked={() => {
        const win = app.get_window("notification-center")
        if (win) win.visible = !win.visible
      }}
    >
      <label label={notifications((n) => (n.length > 0 ? `🔔 ${n.length}` : "🔔"))} />
    </button>
  )
}

function Clock() {
  const time = createPoll("", 1000, "date '+%a, %d. %b  %H:%M'")
  return (
    <button
      class="pill clock-btn"
      onClicked={() => {
        const win = app.get_window("calendar")
        if (win) win.visible = !win.visible
      }}
    >
      <label label={time} />
    </button>
  )
}

function Power() {
  const [open, setOpen] = createState(false)
  const run = (cmd: string[]) => {
    setOpen(false)
    execAsync(cmd).catch(console.error)
  }

  return (
    <box class="pill">
      <revealer
        revealChild={open}
        transitionType={Gtk.RevealerTransitionType.SLIDE_LEFT}
      >
        <box>
          <button
            class="pbtn"
            tooltipText="Sperren"
            onClicked={() => run(["sh", "-c", "pidof hyprlock || hyprlock"])}
          >
            <image iconName="system-lock-screen-symbolic" />
          </button>
          <button
            class="pbtn"
            tooltipText="Neustart"
            onClicked={() => run(["systemctl", "reboot"])}
          >
            <image iconName="system-reboot-symbolic" />
          </button>
          <button
            class="pbtn"
            tooltipText="Herunterfahren"
            onClicked={() => run(["systemctl", "poweroff"])}
          >
            <image iconName="system-shutdown-symbolic" />
          </button>
        </box>
      </revealer>
      <button class="pbtn" tooltipText="Power" onClicked={() => setOpen((v) => !v)}>
        <image iconName="view-more-symbolic" />
      </button>
    </box>
  )
}

function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  return (
    <window
      visible
      name="bar"
      class="Bar"
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <centerbox>
        <box $type="start">
          <Workspaces />
        </box>

        <box $type="center" spacing={6}>
          <Media />
          <Cava />
        </box>

        <box $type="end" spacing={1}>
          <NotifButton />
          <Volume />
          <Clock />
          <Power />
        </box>
      </centerbox>
    </window>
  )
}

app.start({
  main() {
    loadCss()
    monitorFile(`${dir}/colors.css`, loadCss)

    NotificationCenter()
    CalendarWindow()

    app.get_monitors().map(Bar)
  },
})