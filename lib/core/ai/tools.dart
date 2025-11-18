import 'package:firebase_ai/firebase_ai.dart';

final askConfirmationTool = FunctionDeclaration(
  'askConfirmation',
  'Trigger an alert dialog to ask the user for confirmation before executing a change. Only use this tool to ask the user a yes or not question. Do not display any other text',
  parameters: {
    'question': Schema.string(
      description:
          'The question to ask the user for their confirmation to execute to change. The answer to this question is needs to be either "yes" or "no".',
    ),
  },
);
final fontFamilyTool = FunctionDeclaration(
  'setFontFamily',
  'Set the app theme\'s font family',
  parameters: {
    'fontFamily': Schema.string(
      description:
          '''The name of the desired font family. The font family options are: 
             Inter: a carefully designed, open-source sans-serif typeface optimized for computer screens, prioritizing readability with a tall x-height and clean, geometric forms. 
             Raleway: an elegant, thin-weight sans-serif font family, initially designed as a single thin weight, that has expanded to a full range of weights and is known for its distinctive "W," making it suitable for headlines and display text.
             Georgia: is a highly readable serif typeface designed for screen use, characterized by its relatively large x-height and robust design.
             Caveat: Caveat is a friendly and legible handwriting font. It aims to capture the natural feel of handwritten text, making it suitable for both short annotations and longer body text. 
          ''',
    ),
  },
);

final fontSizeFactorTool = FunctionDeclaration(
  'setFontSizeFactor',
  'Set the app theme\'s font size factor, determining how big text appears on the screen. ',
  parameters: {
    'fontSizeFactor': Schema.number(
      format: "double",
      description: '''
             The desired font size factor, which determins how big text appears on the screen. The default value is 1.0.
             The minimum value is 1.0. The maximum value is 2.0. The font size factor should be increase in increments of 0.05 unless the user indicates a value.
          ''',
    ),
  },
);

final appThemeColorTool = FunctionDeclaration(
  'setAppColor',
  'Set the app theme\'s color. You should pick the color, unless the user specifies. When asking the user for confirmation, use a human-friendly description of the color instead of RGB values.',
  parameters: {
    'red': Schema.integer(
      description:
          "The desired app theme color's RGB RED channel value that can range from 0 to 255",
    ),
    'green': Schema.integer(
      description:
          "The desired app theme color's RGB GREEN channel value that can range from 0 to 255",
    ),
    'blue': Schema.integer(
      description:
          "The desired app theme color's RGB BLUE channel that can range from 0 to 255",
    ),
  },
);

final deviceInfoTool = FunctionDeclaration(
  'getDeviceInfo',
  'Get a variety of device information such as type of device, operating system, etc.',
  parameters: {},
);

final batteryInfoTool = FunctionDeclaration(
  'getBatteryInfo',
  'Get device battery information including battery level and whether the device is in battery saving mode.',
  parameters: {},
);

final fileFeedbackTool = FunctionDeclaration(
  'fileFeedback',
  'File a feedback report for the user.',
  parameters: {
    'summary': Schema.string(description: 'A concise summary of the feedback.'),
    'batteryInfo': Schema.string(
      description:
          'If the user complains about app performance, include the battery level & power saving status, ',
      nullable: true,
    ),
    'deviceInfo': Schema.string(
      description:
          'A 2 sentence summary the device information, include the model name, manufacturer, and operating system.',
    ),
    'actionHistory': Schema.string(
      description:
          'The history of actions recommended or made on behalf of the user.',
    ),
    'tags': Schema.array(
      items: Schema.string(description: 'Tags that categorize the feedback'),
      description: 'A list of tags categorizing the feedback.',
    ),
    'priority': Schema.integer(
      description:
          'Assign this feedback a Priority level ranging from 0 (VERY URGENT) to 4 (Low urgency).',
    ),
  },
);
