import { application } from "controllers/application"
import ExerciseController from "controllers/exercise_controller"
import KeyboardController from "controllers/keyboard_controller"
import TimerController from "controllers/timer_controller"

application.register("exercise", ExerciseController)
application.register("keyboard", KeyboardController)
application.register("timer", TimerController)
