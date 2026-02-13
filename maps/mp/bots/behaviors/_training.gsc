/*
	Training can simply be described as a goal of goals, where the goal is to generate a set of goals which form a circular path over time.
	The bot can start at any point on a circular path and it does not need to be a perfect circle; only a polygon.
	The number of points required is the number of successful inputs to define a series of goals that creates a closed loop.
	Defined as data structures:

	struct point
	{
		vec2_t origin;
		float ground_offset; // a point is always offset from ground level by player height; players are limited by gravity for vertical movement
	};

	struct 2_5d_shape
	{
		point verts[];
	};

	Success is defined where verts[last + 1] == verts[first] when generating the next vert(goal).
	We would have arrived at the start.

	Now in order to actually decide how to move to one of these verts we need another few structs:

	struct movement_input
	{
		//int time; // the number of server frames to hold the inputs
		float right; // -128 -> 127
		float forward; // -128 -> 127
		float yaw; // 0 - > 360
		//float pitch; // does not affect forward movement speed and therefore can be left unchanged
		bool jump; // allows for strafe jumps and certain kinds of escapes
		bool sprint;
		stance_t stance; // if crouch, stand or prone is required
	};

	// less common but still possible actions that benefit movement survival.
	struct movement_input_ex
	{
		bool fire_weapon; // tgun etc.
		bool fire_tactical; // monkey bomb etc.
		bool fire_lethal; // grenade etc.
		bool melee; // kill zombie in way
		bool revive; // revive player while circling them
	};

	Each frame a movement_input is processed.


	Now to generate the movement_inputs we need a movement generation params struct:
	struct movement_generation_params
	{
		vec3_t desired_velocity; // forward/backward, right/left, up/down
		vec2_t desired_angles;
	};

	But in order to get that data we need to make predictions; we need yet more structs.

	struct actor_server_frame
	{
		vec3_t origin;
		vec3_t angles;
		bool launched_attacked;
		vec3_t goal;
		gentity_t favorite_enemy; // if we are not currently their favorite they are not targeting us
		int health; // if we kill them they won't be in the way anymore...
	};

	struct zombie_aitype_weapon
	{
		int damage;
		float range;
		float radius;
	};

	struct hitbox
	{
		vec3_t hitbox_maxs;
		vec3_t hitbox_mins;
		bone weakpoints[]; // ordered list of bones to attack from highest to lowest priority
	};

	struct zombie_threat_level
	{
		int aitype;
		int health;
		int max_health;
		int move_speed; // enum
		float anim_rate; // paralzyer
		bool has_legs; // lower threat; allows jumping over as an option
		vec3_t block_maxs; // a path that intersects with these bounds will result in us being stuck
		vec3_t block_mins;
		vec3_t attack_maxs; // a path that intersets with these bounds will leave us vulnerable to attack, but not become stuck
		vec3_t attack_mins;
		hitbox hitbox_;
		zombie_aitype_weapon weapons[]; // the kinds of attacks this zombie can dish out; only special zombies have weapons other than melee
	};

	struct actor_prediction_t
	{
		actor_server_frame[]; // where the actor will be over time
		zombie_threat_level danger; // prefer to path further away from high threat actors like the panzer than closer
	};

	struct player_prediction_t
	{
		struct player_server_frame[]; // where the player will be over time
		vec3_t block_maxs;
		vec3_t block_mins;
	};

	struct CustomSearchInfo_BotHordeing
	{
		pathnode_t pNodeTo;
		actor_prediction_t actor_obstacles[];
		player_prediction_t player_obstacles[];
		vehicle_prediction_t vehicle_obstacles[];

		int skill_level; // determines the number and weighting of stable paths
		int acceptable_risk; // increment if a path cannot be found and try again until death is predicted
	};
*/