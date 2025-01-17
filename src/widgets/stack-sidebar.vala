/* stack-sidebar.vala
 *
 * Copyright 2020-2021 Nahuel Gomez Castro <nahual_gomca@outlook.com.ar>
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

[GtkTemplate (ui = "/com/github/nahuelwexd/Replay/stack-sidebar.ui")]
public class Rpy.StackSidebar : Gtk.Widget {
	private Gtk.Stack? _stack;

	[GtkChild]
	private unowned Gtk.ListBox _list_box;

	public Gtk.Stack? stack {
		get { return this._stack; }
		set {
			if (value == this._stack) {
				return;
			}

			if (this._stack != null) {
				this._stack.pages.selection_changed.disconnect (this.on_stack_pages_selection_changed);
			}

			this._stack = value;

			if (this._stack != null) {
				this._list_box.bind_model (this._stack.pages, this.get_row_from_page);
				this._stack.pages.selection_changed.connect (this.on_stack_pages_selection_changed);

				// The first selection always needs to be done manually
				Gtk.Bitset selection = this._stack.pages.get_selection ();
				this.on_stack_pages_selection_changed (selection.get_nth (0));
			}
		}
	}

	private Gtk.Widget get_row_from_page (Object item) requires (item is Gtk.StackPage) {
		// FIXME: Remove this cast once Fedora valac gains support for type
		//        narrowing
		var stack_page = (Gtk.StackPage) item;

		var icon = new Gtk.Image.from_icon_name (stack_page.icon_name);
		var label = new Gtk.Label (stack_page.title);

		var hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
		hbox.append (icon);
		hbox.append (label);

		return hbox;
	}

	[GtkCallback]
	private void on_list_box_row_activated (Gtk.ListBoxRow row) {
		// Due to the fact that the pages of the stack are binded to the list
		// box, we can assume that the items are in the same order
		this.stack.pages.select_item (row.get_index (), true);
		this._list_box.select_row (row);
	}

	private void on_stack_pages_selection_changed (uint position) {
		var row_selected = this._list_box.get_row_at_index ((int) position);
		this._list_box.select_row (row_selected);
	}

	public override void dispose () {
		this._list_box.unparent ();
		base.dispose ();
	}

	static construct {
		set_css_name ("stacksidebar");
	}
}
