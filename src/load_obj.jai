// Everett
// Load OBJ Files
// Alex Hartford
// June 2023

// @NOTE: This code is adapted from CyanMARgh's code on github.
// As far as I know, it is open-source.
// Let me know if I should take this down or put a license here.

OBJ_Type :: enum_flags u8 {
	P       :: 0b_001;
	UV      :: 0b_011;
	N       :: 0b_101;
	UVN     :: 0b_111;
	INVALID :: 0b_000;
}

Parsed_Vertex :: struct {
	ids : [3]int;
	type := OBJ_Type.INVALID;
}

Face :: struct {
	MAX_POINTS :: 6;

	ids : [MAX_POINTS * 3]int;
	count : u8;
	type := OBJ_Type.INVALID;
}

load_obj :: (obj_path: string) -> Mesh, bool {
	obj_data, success := read_entire_file(obj_path);
	if !success {
		print("couldn't load file: %\n", obj_path);
		return .{}, false;
	} 
	defer free(obj_data);
	obj_view := obj_data;

	end :: ($$ok := false, info := "") #expand {
		if !ok {
			print("failed to load mesh (%), invalid line: %\n", `obj_path, `line_id);
			if info != "" then print("extra info: %\n", info);
			array_free(points);
			array_free(uvs);
			array_free(normals);
			array_free(faces);
			`return .{}, false;
		}
	}

	parse_vec :: (separator : *string, $T : Type) -> T, bool {
		v : T;
		for * e : v.component {
			ok : bool;
			<<e, ok = parse_float(separator); if !ok return .{}, false;
		}
		s, ok_suffix := parse_token(separator);
		if ok_suffix && s[0] != #char "#" return .{}, false;

		return v, true;
	}

	parse_vertex :: (src : string) -> Parsed_Vertex {
		c :: (x : Any) -> int {return <<cast(*int)x.value_pointer;}

		using result : Parsed_Vertex;
		ok, r := scan("%i", src); if ok {
			ids[0] = c(r[0]); type = .P;
			return result;
		} 
		ok, r = scan("%i/%i", src); if ok {
			ids[0], ids[1] = c(r[0]), c(r[1]); type = .UV;
			return result;
		}
		ok, r = scan("%i//%i", src); if ok {
			ids[0], ids[2] = c(r[0]), c(r[1]); type = .N;
			return result;
		}
		ok, r = scan("%i/%i/%i", src); if ok {
			ids[0], ids[1], ids[2] = c(r[0]), c(r[1]), c(r[2]); type = .UVN;
			return result;
		}
		return result;
	}

	parse_face :: (str : *string) -> Face {
		vts : [Face.MAX_POINTS]Parsed_Vertex;
		count : u8 = 0;
		while count < Face.MAX_POINTS {
			token, ok := parse_token(str);
			if !ok break;
			if count == Face.MAX_POINTS - 1 {
				if token[0] == #char"#" break;
				return .{type=.INVALID};
			}
			vts[count] = parse_vertex(token);
			t := vts[count].type;
			if t == .INVALID {
				return .{type=.INVALID};
			}
			count += 1;
		}
		if count < 3 return .{type=.INVALID};	
		face := Face.{type = vts[0].type, count = count};
		for i : 0..count-1 {
			for j : 0..2 {
				if vts[i].type != face.type return .{type=.INVALID};
				face.ids[i * 3 + j] = vts[i].ids[j];
			}
		}
		return face;
	}

	fix_ids :: (f : *Face, l : [3]int) -> bool {
		for j : 0..2 {
			if (cast(s64) f.type) & (1 << j) {
				for i : 0..f.count-1 {
					id := f.ids[i * 3 + j];
					id = ifx id < 0 then l[j] + id else id - 1;
					if id < 0 || id >= l[j] return false;
					f.ids[i * 3 + j] = id;
				}
			} else {
				for i : 0..f.count-1 f.ids[i * 3 + j] = -1;
			}
		}
		return true;
	}

	points : [..] Vector3;
	uvs : [..] Vector2;
	normals : [..] Vector3;
	faces : [..] Face;
	most_general := OBJ_Type.INVALID;

	line_id := 0;
	while 1 {
		line_id += 1;
		line, ok_line := parse_token(*obj_view, "", "\n");
		if !ok_line break;

		prefix, ok_prefix := parse_token(*line); if !ok_prefix continue;

		if prefix == {
			case "v";
			pos : Vector3; ok_v : bool;
			pos, ok_v = parse_vec(*line, Vector3); end(ok_v, "(0)");
			array_add(*points, pos);

			case "vt";
			uv, ok_vt := parse_vec(*line, Vector2); end(ok_vt, "(1)");
			array_add(*uvs, uv);

			case "vn";
			pos, ok_vn := parse_vec(*line, Vector3); end(ok_vn, "(2)");
			array_add(*normals, pos);

			case "f";
			face := parse_face(*line); end(face.type != .INVALID, "(3)");

			ls : [3]int; ls[0], ls[1], ls[2] = points.count, uvs.count, normals.count;
			end(fix_ids(*face, ls), "(4)");

			most_general |= face.type;
			array_add(*faces, face);

			case "o"; #through;
			case "g"; #through;
			case "s"; #through;
			case "mtllib"; #through;
			case "usemtl";
			print("prefix % not supported yet\n", prefix);

			case;
			end(prefix[0] == #char "#", "(5)");
			continue;
		}
	}
	return .{points=points, uvs=uvs, normals=normals, faces=faces}, true;
}
