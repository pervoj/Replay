/* Copyright (C) 2019 Nucleux Software
 *
 * This file is part of unitube-gtk.
 *
 * unitube-gtk is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * unitube-gtk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY of FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with unitube-gtk.  If not, see <https://www.gnu.org/licenses/>.
 *
 * Author: Nahuel Gomez Castro <nahual_gomca@outlook.com.ar>
 */

class UniTube.Core.VideoListRequest : Request<VideoListResponse> {

	public VideoListRequest (string part) {
		this.part = part;
	}

	public string? part {
		owned get {
			return this.get_property_string ("part");
		}
		private set {
			this.set_property_string ("part", value);
		}
	}

	public string? chart {
		owned get {
			return this.get_property_string ("chart");
		}
		set {
			this.set_property_string ("chart", value);
		}
	}

	public string? id {
		owned get {
			return this.get_property_string ("id");
		}
		set {
			this.set_property_string ("id", value);
		}
	}

	public string? my_rating {
		owned get {
			return this.get_property_string ("myRating");
		}
		set {
			this.set_property_string ("myRating", value);
		}
	}

	public string? hl {
		owned get {
			return this.get_property_string ("hl");
		}
		set {
			this.set_property_string ("hl", value);
		}
	}

	public long max_height {
		get {
			return this.get_property_long ("maxHeight");
		}
		set {
			this.set_property_long ("maxHeight", value);
		}
	}

	public long max_results {
		get {
			return this.get_property_long ("maxResults");
		}
		set {
			this.set_property_long ("maxResults", value);
		}
	}

	public long max_width {
		get {
			return this.get_property_long ("maxWidth");
		}
		set {
			this.set_property_long ("maxWidth", value);
		}
	}

	public string? on_behalf_of_content_owner {
		owned get {
			return this.get_property_string ("onBehalfOfContentOwner");
		}
		set {
			this.set_property_string ("onBehalfOfContentOwner", value);
		}
	}

	public string? page_token {
		owned get {
			return this.get_property_string ("pageToken");
		}
		set {
			this.set_property_string ("pageToken", value);
		}
	}

	public string? region_code {
		owned get {
			return this.get_property_string ("regionCode");
		}
		set {
			this.set_property_string ("regionCode", value);
		}
	}

	public string? video_category_id {
		owned get {
			return this.get_property_string ("videoCategoryId");
		}
		set {
			this.set_property_string ("videoCategoryId", value);
		}
	}

	public override VideoListResponse execute () throws ApiError {
		var parameters = this.get_parameters ();
		var session = new Soup.Session ();

		var message = new Soup.Message ("GET",
			@"https://www.googleapis.com/youtube/v3/videos?$parameters");
		var status_code = session.send_message (message);

		if (status_code == 200) {
			var content_response = (string) message.response_body.data;
			GJson.Object gjson_object = null;

			try {
				gjson_object = GJson.Object.parse (content_response);
			} catch (Error e) {
				throw new ApiError.JSON_PARSE_ERROR (@"Error $(e.message)");
			}

			return (VideoListResponse) GJson.deserialize_object (
				typeof (VideoListResponse), gjson_object);
		} else {
			throw new ApiError.HTTP_REQUEST_ERROR (
				@"Error $(status_code)\n$(message.reason_phrase)\n" +
				"$((string) message.response_body.data)");
		}
	}

	public async override VideoListResponse execute_async () throws ApiError {
		VideoListResponse response = null;
		ThreadFunc<void*> func = () => {
			response = execute ();
			Idle.add (execute_async.callback);
			return null;
		};
		Thread.create (func, false);
		yield;
		return response;
	}
}