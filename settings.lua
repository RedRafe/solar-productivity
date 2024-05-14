data:extend({
  {
		type = 'int-setting',
		name = 'sp:interval',
		setting_type = 'runtime-global',
		order = 'sp:1',
		default_value = 5,
		minimum_value = 1,
		maximum_value = 60 * 60 --1h
	},
})