/* header-bar.vala
 *
 * Copyright 2019-2021 Nahuel Gomez Castro <nahual_gomca@outlook.com.ar>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

[GtkTemplate (ui = "/com/github/nahuelwexd/Replay/header-bar.ui")]
public class Rpy.HeaderBar : Gtk.Widget {
	private unowned Gtk.Widget? _capture_widget;
	private Gtk.EventControllerKey? _capture_widget_controller;

	[GtkChild]
	private unowned Adw.HeaderBar _header_bar;

	[GtkChild]
	private unowned Gtk.SearchEntry _search_entry;

	public bool can_go_back { get; set; }

	// Some bits stolen from
	// https://gitlab.gnome.org/GNOME/gtk/-/blob/master/gtk/gtksearchbar.c and
	// ported to Vala.
	public unowned Gtk.Widget? key_capture_widget {
		get { return this._capture_widget; }
		set {
			if (value == this._capture_widget) {
				return;
			}

			if (this._capture_widget != null) {
				this._capture_widget.remove_controller (this._capture_widget_controller);
			}

			this._capture_widget = value;

			if (this._capture_widget != null) {
				this._capture_widget_controller = new Gtk.EventControllerKey () {
					propagation_phase = Gtk.PropagationPhase.CAPTURE
				};

				this._capture_widget_controller.key_pressed.connect (this.capture_widget_key_handled);
				this._capture_widget_controller.key_released.connect (() => this.capture_widget_key_handled ());

				this._capture_widget.add_controller (this._capture_widget_controller);
            }
        }
    }

	public string title { get; set; }
	public bool title_visible { get; set; }

	public override void dispose () {
		this._header_bar.unparent ();
		base.dispose ();
	}

	// More bits stolen from
	// https://gitlab.gnome.org/GNOME/gtk/-/blob/master/gtk/gtksearchbar.c,
	// ported to Vala and modified for Replay
	private bool capture_widget_key_handled () {
		if (!this.get_mapped ()) {
			return Gdk.EVENT_PROPAGATE;
		}

		if (this.title_visible) {
			return Gdk.EVENT_PROPAGATE;
		}

		if (this._search_entry.has_focus) {
			return Gdk.EVENT_PROPAGATE;
		}

		bool handled = this._capture_widget_controller.forward (this);

		if (handled == Gdk.EVENT_STOP) {
			this._search_entry.grab_focus ();
			this._search_entry.set_position (int.MAX);
		}

		return handled;
	}

	[GtkCallback]
	private void on_search_entry_stop_search () {
		this._search_entry.text = "";
	}

	construct {
		this._search_entry.set_key_capture_widget (this);
	}
}
