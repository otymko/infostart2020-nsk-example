@chcp 65001

@call vrunner init-dev --dt ‪"build/dt/base.dt" --settings ./vb-params.json
@call vrunner compileext --settings ./vb-params.json --updatedb