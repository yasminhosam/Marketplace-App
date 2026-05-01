import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marketplace_app/features/customer_orders/cubit/customer_orders_cubit.dart';
import 'package:marketplace_app/features/customer_orders/cubit/customer_orders_state.dart';
import 'package:marketplace_app/features/customer_orders/UI/order_card.dart';

class CustomerOrdersScreen
    extends StatefulWidget {
  const CustomerOrdersScreen({
    super.key,
  });

  @override
  State<CustomerOrdersScreen>
  createState() =>
      _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState
    extends
        State<CustomerOrdersScreen> {
  @override
  Widget build(BuildContext context) {
    final clientId =
        FirebaseAuth
            .instance
            .currentUser
            ?.uid ??
        "";

    return BlocProvider(
      create: (context) =>
          CustomerOrdersCubit()
            ..fetchClientOrders(
              clientId,
            ),
      child: Scaffold(
        backgroundColor: const Color(
          0xFF101622,
        ),
        appBar: AppBar(
          backgroundColor: const Color(
            0xFF101622,
          ),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'My Orders',
            style: TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        body: BlocBuilder<
                    CustomerOrdersCubit,
                    CustomerOrdersState
                  >(
                    builder: (context, state) {
                      if (state is CustomerOrdersLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(
                              0xff135EF3,
                            ),
                          ),
                        );
                      } else if (state
                          is CustomerOrdersError) {
                        return Center(
                          child: Text(
                            state
                                .errorMessage,
                            style: const TextStyle(
                              color: Colors
                                  .red,
                            ),
                          ),
                        );
                      } else if (state
                          is CustomerOrdersLoaded) {
                        final orders = state.orders;

                        if (orders.isEmpty) {
                          return const Center(
                            child: Text(
                              "No orders found",
                              style: TextStyle(
                                color: Color(
                                  0xFF8B9CB6,
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          padding:
                              const EdgeInsets.all(
                                16,
                              ),
                          itemCount:
                              orders.length,
                          separatorBuilder:
                              (
                                _,
                                _,
                              ) => const SizedBox(
                                height:
                                    16,
                              ),
                          itemBuilder:
                              (
                                context,
                                index,
                              ) => OrderCard(
                                order:
                                    orders[index],
                              ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
      ),
    );
  }
}
