if exists("g:__windex_loaded")
    finish
endif
let g:__windex_loaded = 1

" Setup:
if !exists("g:__windex_setup_completed")
    lua require('windex').setup()
endif

