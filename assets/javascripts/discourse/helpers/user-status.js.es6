import { iconHTML } from 'discourse-common/lib/icon-library';
import { htmlHelper } from 'discourse-common/lib/helpers';
import { escapeExpression } from 'discourse/lib/utilities';

export default htmlHelper((user, args) => {
  if (!user) { return; }

  const name = escapeExpression(user.get('name'));
  let currentUser;
  if (args && args.hash) {
    currentUser = args.hash.currentUser;
  }
});