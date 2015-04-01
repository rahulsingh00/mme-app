class CreateVwPayments < ActiveRecord::Migration
  def change
    create_view :vw_payments, 'select artist_goals.user_id as "artist_id",
			artist_goals.goal_amount,
			sum(pay.pledged_amount) as "raised_amount",
			phase_ledgers.phase,
			MAX(CASE WHEN pay.status=\'c\' then pay.pledged_amount else 0.0 end ) as "charged_amount",
			MAX(CASE WHEN pay.status=\'u\' then pay.pledged_amount else 0.0 end ) as "uncharged_amount"
			from artist_goals
			inner join phase_ledgers on (phase_ledgers.user_id=artist_goals.user_id and phase_ledgers.trashed=0)
			inner join
			(select
			artist_id,
			status,
			sum(amount) as "pledged_amount"
			from payment_details group by artist_id,status) pay on (pay.artist_id=artist_goals.user_id)
			group by artist_goals.user_id,
			artist_goals.goal_amount,
			phase_ledgers.phase;'
  end
end
