data:extend({
  {
		type = 'int-setting',
		name = 'sp-interval',
		setting_type = 'runtime-global',
		order = 'sp:1',
		default_value = 5,
		minimum_value = 1,
		maximum_value = 60 * 60 --1h
	},
	{
		type = 'int-setting',
		name = 'sp-multiplier',
		setting_type = 'startup',
		order = 'sp:2',
		default_value = 3,
		minimum_value = 1,
		maximum_value = 10,
	},
})
