import 'package:glow_vita_salon/model/feedback.dart';

class FeedbackController {
  final List<Reviews> _feedbacks = [
    const Reviews(
      name: 'Vishakha Deshmukh',
      imageUrl: 'https://i.pravatar.cc/150?img=47',
      date: 'Dec 5, 2025',
      rating: 4.5,
      comment: 'Absolutely wonderful experience at this salon! The staff is incredibly professional and welcoming.',
    ),
    const Reviews(
      name: 'Vishakha Deshmukh',
      imageUrl: 'https://i.pravatar.cc/150?img=48',
      date: 'Nov 8, 2025',
      rating: 3.5,
      comment: 'Absolutely wonderful experience at this salon! The staff is incredibly professional and welcoming.',
    ),
    const Reviews(
      name: 'Parth Deshmukh',
      imageUrl: 'https://i.pravatar.cc/150?img=11',
      date: 'Aug 2, 2025',
      rating: 4.0,
      comment: 'Absolutely wonderful experience at this salon! The staff is incredibly professional and welcoming.',
    ),
  ];

  List<Reviews> get feedbacks => _feedbacks;
}
